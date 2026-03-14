from datetime import datetime
from uuid import uuid4

from sqlalchemy import Column, DateTime, Float, ForeignKey, String, Text
from sqlalchemy.types import JSON
from sqlalchemy.orm import relationship

from app.database import Base


class PhishingAnalysis(Base):
    __tablename__ = "phishing_analyses"

    id = Column(String, primary_key=True, default=lambda: str(uuid4()))
    user_id = Column(String, ForeignKey("users.id"), nullable=True)
    classification = Column(String, nullable=False)
    confidence_score = Column(Float, nullable=False)
    suspicious_elements = Column(JSON, nullable=False, default=list)
    explanation = Column(Text, nullable=False)
    input_type = Column(String, nullable=False)
    input_content = Column(Text, nullable=False)
    analyzed_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="scans")
