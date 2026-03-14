from datetime import datetime
from uuid import uuid4

from sqlalchemy import Boolean, Column, DateTime, ForeignKey, Integer, String
from sqlalchemy.types import JSON

from app.database import Base


class IncidentResponse(Base):
    __tablename__ = "incident_responses"

    id = Column(String, primary_key=True, default=lambda: str(uuid4()))
    user_id = Column(String, ForeignKey("users.id"), nullable=True)
    incident_type = Column(String, nullable=False)
    risk_level = Column(String, nullable=False)
    user_role = Column(String, nullable=False)
    phases = Column(JSON, nullable=False)
    emergency_contacts = Column(JSON, nullable=False)
    requires_escalation = Column(Boolean, default=False)
    escalation_reason = Column(String, nullable=True)
    generated_at = Column(DateTime, default=datetime.utcnow)


class EmergencyContact(Base):
    __tablename__ = "emergency_contacts"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String, nullable=False)
    role = Column(String, nullable=False)
    phone = Column(String, nullable=False)
    email = Column(String, nullable=False)
