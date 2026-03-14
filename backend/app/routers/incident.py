from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from app.dependencies import get_db, get_optional_user
from app.models.incident import IncidentResponse, EmergencyContact
from app.models.user import User
from app.schemas.incident import IncidentResponseOut, StepUpdateRequest, EmergencyContactOut
from app.services.incident_generator import generate_incident_response

router = APIRouter()


def _format_incident_response(ir: IncidentResponse) -> dict:
    """Convert the DB model to the response format expected by IncidentResponseOut."""
    # The DB stores phases as a list of phase dicts; the schema expects
    # dict[str, list[ResponseStepOut]] keyed by phase_name.
    raw_phases = ir.phases or []
    phases_dict = {}
    for phase in raw_phases:
        phase_name = phase.get("phase_name", "unknown")
        steps = []
        for step in phase.get("steps", []):
            steps.append({
                "id": step["id"],
                "order": step["order"],
                "title": step["title"],
                "description": step["description"],
                "action_required": step.get("action_required", ""),
                "is_completed": step.get("is_completed", False),
                "estimated_duration_minutes": step.get("estimated_duration_minutes"),
                "applicable_roles": step.get("applicable_roles", []),
            })
        phases_dict[phase_name] = steps

    emergency_contacts = ir.emergency_contacts or []

    return {
        "id": ir.id,
        "incident_type": ir.incident_type,
        "risk_level": ir.risk_level,
        "user_role": ir.user_role,
        "phases": phases_dict,
        "emergency_contacts": emergency_contacts,
        "requires_escalation": ir.requires_escalation,
        "escalation_reason": ir.escalation_reason,
        "generated_at": ir.generated_at.isoformat() + "Z" if ir.generated_at else "",
    }


@router.get("/emergency-contacts")
async def get_emergency_contacts(
    db: Session = Depends(get_db),
):
    contacts = db.query(EmergencyContact).all()
    return [
        {
            "name": c.name,
            "role": c.role,
            "phone": c.phone,
            "email": c.email,
        }
        for c in contacts
    ]


@router.get("")
async def get_incident_response(
    incident_type: str = Query(...),
    user_role: str = Query(...),
    db: Session = Depends(get_db),
    current_user: User | None = Depends(get_optional_user),
):
    result = generate_incident_response(incident_type, user_role)

    # Save to DB
    ir = IncidentResponse(
        id=result["id"],
        user_id=current_user.id if current_user else None,
        incident_type=result["incident_type"],
        risk_level=result["risk_level"],
        user_role=user_role,
        phases=result["phases"],
        emergency_contacts=result["emergency_contacts"],
        requires_escalation=result["requires_escalation"],
        escalation_reason=result.get("escalation_reason"),
    )
    db.add(ir)
    db.commit()
    db.refresh(ir)

    return _format_incident_response(ir)


@router.post("/{response_id}/steps/{step_id}")
async def update_step(
    response_id: str,
    step_id: str,
    body: StepUpdateRequest,
    db: Session = Depends(get_db),
):
    ir = db.query(IncidentResponse).filter(IncidentResponse.id == response_id).first()
    if ir is None:
        raise HTTPException(status_code=404, detail="Incident response not found")

    # Find and update the step in the phases list
    phases = ir.phases or []
    step_found = False
    for phase in phases:
        for step in phase.get("steps", []):
            if step.get("id") == step_id:
                step["is_completed"] = body.is_completed
                step_found = True
                break
        if step_found:
            break

    if not step_found:
        raise HTTPException(status_code=404, detail="Step not found")

    # Persist the updated phases JSON
    ir.phases = phases
    from sqlalchemy.orm.attributes import flag_modified
    flag_modified(ir, "phases")
    db.commit()
    db.refresh(ir)

    return _format_incident_response(ir)
