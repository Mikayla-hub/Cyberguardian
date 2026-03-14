from datetime import datetime

from sqlalchemy import Column, DateTime, Float, ForeignKey, String, Text
from sqlalchemy.orm import relationship

from app.database import Base


class PhishingReport(Base):
    __tablename__ = "phishing_reports"

    case_id = Column(String, primary_key=True)
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    category = Column(String, nullable=False)
    status = Column(String, default="submitted")
    content_text = Column(Text, nullable=False)
    url = Column(String, nullable=True)
    screenshot_path = Column(String, nullable=True)
    ai_confidence = Column(Float, nullable=False)
    ai_explanation = Column(Text, nullable=False)
    submitted_at = Column(DateTime, default=datetime.utcnow)
    resolved_at = Column(DateTime, nullable=True)

    user = relationship("User", back_populates="reports")
