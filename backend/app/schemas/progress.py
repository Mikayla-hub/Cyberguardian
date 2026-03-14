from pydantic import BaseModel


class BadgeOut(BaseModel):
    id: str
    name: str
    description: str
    icon_url: str
    earned_at: str


class UserProgressOut(BaseModel):
    user_id: str
    total_xp: int
    current_level: int
    phishing_risk_score: float
    completed_lesson_ids: list[str]
    badges: list[BadgeOut]
    quiz_scores: dict[str, int]
    streak_days: int
    last_activity_date: str


class CompleteLessonRequest(BaseModel):
    quiz_score: int


class AwardXpRequest(BaseModel):
    amount: int
