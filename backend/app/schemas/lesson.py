from pydantic import BaseModel


class LessonContentOut(BaseModel):
    type: str
    data: str
    metadata: dict | None = None


class QuizQuestionOut(BaseModel):
    id: str
    question: str
    options: list[str]
    correct_index: int
    explanation: str


class LessonOut(BaseModel):
    id: str
    title: str
    description: str
    category: str
    difficulty: str
    duration_minutes: int
    contents: list[LessonContentOut]
    quiz: list[QuizQuestionOut]
    xp_reward: int
    badge_id: str | None = None
