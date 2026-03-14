from datetime import datetime

from sqlalchemy import Column, DateTime, Float, ForeignKey, Integer, String
from sqlalchemy.types import JSON
from sqlalchemy.orm import relationship

from app.database import Base


class UserProgress(Base):
    __tablename__ = "user_progress"

    user_id = Column(String, ForeignKey("users.id"), primary_key=True)
    total_xp = Column(Integer, default=0)
    current_level = Column(Integer, default=1)
    phishing_risk_score = Column(Float, default=1.0)
    completed_lesson_ids = Column(JSON, default=list)
    badges = Column(JSON, default=list)
    quiz_scores = Column(JSON, default=dict)
    streak_days = Column(Integer, default=0)
    last_activity_date = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="progress")
