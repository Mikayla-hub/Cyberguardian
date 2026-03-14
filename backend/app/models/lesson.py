from sqlalchemy import Column, Integer, String, Text
from sqlalchemy.types import JSON

from app.database import Base


class Lesson(Base):
    __tablename__ = "lessons"

    id = Column(String, primary_key=True)
    title = Column(String, nullable=False)
    description = Column(Text, nullable=False)
    category = Column(String, nullable=False)
    difficulty = Column(String, nullable=False)
    duration_minutes = Column(Integer, nullable=False)
    contents = Column(JSON, nullable=False)
    quiz = Column(JSON, nullable=False)
    xp_reward = Column(Integer, nullable=False, default=50)
    badge_id = Column(String, nullable=True)
