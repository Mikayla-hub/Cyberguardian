from pydantic import BaseModel


class ResponseStepOut(BaseModel):
    id: str
    order: int
    title: str
    description: str
    action_required: str
    is_completed: bool = False
    estimated_duration_minutes: int | None = None
    applicable_roles: list[str]


class EmergencyContactOut(BaseModel):
    name: str
    role: str
    phone: str
    email: str


class IncidentResponseOut(BaseModel):
    id: str
    incident_type: str
    risk_level: str
    user_role: str
    phases: dict[str, list[ResponseStepOut]]
    emergency_contacts: list[EmergencyContactOut]
    requires_escalation: bool
    escalation_reason: str | None = None
    generated_at: str


class StepUpdateRequest(BaseModel):
    is_completed: bool
