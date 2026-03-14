from uuid import uuid4
from datetime import datetime


def generate_incident_response(incident_type: str, user_role: str) -> dict:
    """Generate a full incident response plan matching the Flutter mock."""
    risk_level = "high" if incident_type in ("emailPhishing", "socialEngineering") else "medium"
    requires_escalation = risk_level == "high" and user_role == "employee"

    emergency_contacts = [
        {
            "name": "IT Security Team",
            "role": "Primary Response",
            "phone": "+1-555-SEC-TEAM",
            "email": "security@company.com",
            "available_24_7": True,
        },
        {
            "name": "Help Desk",
            "role": "General Support",
            "phone": "+1-555-HELP-NOW",
            "email": "helpdesk@company.com",
            "available_24_7": True,
        },
        {
            "name": "CISO Office",
            "role": "Executive Escalation",
            "phone": "+1-555-CISO-OFF",
            "email": "ciso@company.com",
            "available_24_7": False,
        },
    ]

    phases = [
        {
            "phase_name": "identification",
            "description": "Identify and document the security incident.",
            "order": 1,
            "steps": [
                {
                    "id": "s1",
                    "order": 1,
                    "title": "Document the incident",
                    "description": "Record all details about the suspected phishing attempt including timestamps, sender information, and content.",
                    "action_required": "Complete this step as described above.",
                    "is_completed": False,
                    "estimated_duration_minutes": None,
                    "applicable_roles": ["employee", "admin", "it"],
                },
                {
                    "id": "s2",
                    "order": 2,
                    "title": "Identify the attack type",
                    "description": "Determine whether this is email phishing, SMS phishing, website spoofing, or social engineering.",
                    "action_required": "Complete this step as described above.",
                    "is_completed": False,
                    "estimated_duration_minutes": None,
                    "applicable_roles": ["employee", "admin", "it"],
                },
                {
                    "id": "s3",
                    "order": 3,
                    "title": "Assess potential data exposure",
                    "description": "Determine if any sensitive data (credentials, financial info, personal data) may have been compromised.",
                    "action_required": "Complete this step as described above.",
                    "is_completed": False,
                    "estimated_duration_minutes": None,
                    "applicable_roles": ["employee", "admin", "it"],
                },
            ],
        },
        {
            "phase_name": "containment",
            "description": "Contain the threat to prevent further damage.",
            "order": 2,
            "steps": [
                {
                    "id": "s4",
                    "order": 1,
                    "title": "Change compromised passwords",
                    "description": "Immediately change passwords for any accounts that may have been compromised.",
                    "action_required": "Complete this step as described above.",
                    "is_completed": False,
                    "estimated_duration_minutes": 10,
                    "applicable_roles": ["employee", "admin", "it"],
                },
                {
                    "id": "s5",
                    "order": 2,
                    "title": "Disconnect affected systems if needed",
                    "description": "If malware is suspected, disconnect the affected device from the network to prevent spread.",
                    "action_required": "Complete this step as described above.",
                    "is_completed": False,
                    "estimated_duration_minutes": 2,
                    "applicable_roles": ["employee", "admin", "it"],
                },
                {
                    "id": "s6",
                    "order": 3,
                    "title": "Block the sender/source",
                    "description": "Block the phishing sender or malicious URL at the email gateway or firewall level.",
                    "action_required": "Complete this step as described above.",
                    "is_completed": False,
                    "estimated_duration_minutes": None,
                    "applicable_roles": ["admin", "it"],
                },
                {
                    "id": "s7",
                    "order": 4,
                    "title": "Quarantine affected systems",
                    "description": "Isolate any systems that may have been compromised to prevent lateral movement.",
                    "action_required": "Complete this step as described above.",
                    "is_completed": False,
                    "estimated_duration_minutes": 30,
                    "applicable_roles": ["admin", "it"],
                },
            ],
        },
        {
            "phase_name": "reporting",
            "description": "Report the incident through proper channels.",
            "order": 3,
            "steps": [
                {
                    "id": "s8",
                    "order": 1,
                    "title": "Report to IT Security team",
                    "description": "Submit a detailed incident report to the IT Security team with all gathered evidence.",
                    "action_required": "Complete this step as described above.",
                    "is_completed": False,
                    "estimated_duration_minutes": 5,
                    "applicable_roles": ["employee", "admin", "it"],
                },
                {
                    "id": "s9",
                    "order": 2,
                    "title": "File a formal incident report",
                    "description": "Complete the formal incident report form including all technical details and impact assessment.",
                    "action_required": "Complete this step as described above.",
                    "is_completed": False,
                    "estimated_duration_minutes": 15,
                    "applicable_roles": ["admin", "it"],
                },
            ],
        },
        {
            "phase_name": "recovery",
            "description": "Recover from the incident and restore normal operations.",
            "order": 4,
            "steps": [
                {
                    "id": "s10",
                    "order": 1,
                    "title": "Verify account security",
                    "description": "Confirm that all compromised accounts have been secured and verify no unauthorized changes were made.",
                    "action_required": "Complete this step as described above.",
                    "is_completed": False,
                    "estimated_duration_minutes": 15,
                    "applicable_roles": ["employee", "admin", "it"],
                },
                {
                    "id": "s11",
                    "order": 2,
                    "title": "Scan for malware",
                    "description": "Run a full system scan on affected devices to detect and remove any malware that may have been installed.",
                    "action_required": "Complete this step as described above.",
                    "is_completed": False,
                    "estimated_duration_minutes": 30,
                    "applicable_roles": ["employee", "admin", "it"],
                },
            ],
        },
        {
            "phase_name": "postIncidentReview",
            "description": "Review the incident and improve defenses.",
            "order": 5,
            "steps": [
                {
                    "id": "s12",
                    "order": 1,
                    "title": "Complete security training lesson",
                    "description": "Complete the relevant phishing awareness training lesson to reinforce security knowledge.",
                    "action_required": "Complete this step as described above.",
                    "is_completed": False,
                    "estimated_duration_minutes": 15,
                    "applicable_roles": ["employee", "admin", "it"],
                },
                {
                    "id": "s13",
                    "order": 2,
                    "title": "Review and update security policies",
                    "description": "Review current security policies and update them based on lessons learned from this incident.",
                    "action_required": "Complete this step as described above.",
                    "is_completed": False,
                    "estimated_duration_minutes": 60,
                    "applicable_roles": ["admin", "it"],
                },
            ],
        },
    ]

    escalation_reason = None
    if requires_escalation:
        escalation_reason = (
            "High-risk incident detected. As an employee, this incident requires "
            "immediate escalation to the IT Security team for proper handling."
        )

    return {
        "id": str(uuid4()),
        "incident_type": incident_type,
        "risk_level": risk_level,
        "requires_escalation": requires_escalation,
        "escalation_reason": escalation_reason,
        "emergency_contacts": emergency_contacts,
        "phases": phases,
        "generated_at": datetime.utcnow().isoformat() + "Z",
    }
