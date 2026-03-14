from datetime import datetime
from typing import List

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.dependencies import get_current_user, get_db
from app.models.lesson import Lesson
from app.models.progress import UserProgress
from app.models.user import User
from app.schemas.lesson import LessonOut
from app.schemas.progress import CompleteLessonRequest, UserProgressOut
from app.services.progress_service import calculate_level, calculate_risk_score, check_badge_awards
from sqlalchemy.orm.attributes import flag_modified

router = APIRouter()


def _lesson_response(lesson: Lesson) -> dict:
    return {
        "id": lesson.id,
        "title": lesson.title,
        "description": lesson.description,
        "category": lesson.category,
        "difficulty": lesson.difficulty,
        "duration_minutes": lesson.duration_minutes,
        "contents": lesson.contents or [],
        "quiz": lesson.quiz or [],
        "xp_reward": lesson.xp_reward,
        "badge_id": lesson.badge_id,
    }


def _progress_response(progress: UserProgress) -> dict:
    return {
        "user_id": progress.user_id,
        "total_xp": progress.total_xp,
        "current_level": progress.current_level,
        "phishing_risk_score": progress.phishing_risk_score,
        "completed_lesson_ids": progress.completed_lesson_ids or [],
        "badges": progress.badges or [],
        "quiz_scores": progress.quiz_scores or {},
        "streak_days": progress.streak_days,
        "last_activity_date": progress.last_activity_date.isoformat() + "Z" if progress.last_activity_date else "",
    }


@router.get("", response_model=List[LessonOut])
async def get_all_lessons(db: Session = Depends(get_db)):
    lessons = db.query(Lesson).all()
    return [_lesson_response(lesson) for lesson in lessons]


@router.get("/recommended", response_model=List[LessonOut])
async def get_recommended_lessons(
    user_id: str = Query(...),
    db: Session = Depends(get_db),
):
    progress = db.query(UserProgress).filter(UserProgress.user_id == user_id).first()

    if not progress:
        lessons = db.query(Lesson).all()
        return [_lesson_response(lesson) for lesson in lessons]

    completed_ids = progress.completed_lesson_ids or []
    lessons = db.query(Lesson).filter(Lesson.id.notin_(completed_ids)).all()
    return [_lesson_response(lesson) for lesson in lessons]


@router.get("/{lesson_id}", response_model=LessonOut)
async def get_lesson(lesson_id: str, db: Session = Depends(get_db)):
    lesson = db.query(Lesson).filter(Lesson.id == lesson_id).first()
    if not lesson:
        raise HTTPException(status_code=404, detail="Lesson not found")
    return _lesson_response(lesson)


@router.post("/{lesson_id}/complete", response_model=UserProgressOut)
async def complete_lesson(
    lesson_id: str,
    body: CompleteLessonRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    lesson = db.query(Lesson).filter(Lesson.id == lesson_id).first()
    if not lesson:
        raise HTTPException(status_code=404, detail="Lesson not found")

    progress = db.query(UserProgress).filter(UserProgress.user_id == current_user.id).first()
    if not progress:
        progress = UserProgress(
            user_id=current_user.id,
            total_xp=0,
            current_level=1,
            phishing_risk_score=50,
            completed_lesson_ids=[],
            badges=[],
            quiz_scores={},
            streak_days=0,
            last_activity_date=None,
        )
        db.add(progress)

    completed_ids = list(progress.completed_lesson_ids or [])
    if lesson_id not in completed_ids:
        # Add lesson to completed list
        completed_ids.append(lesson_id)
        progress.completed_lesson_ids = completed_ids
        flag_modified(progress, "completed_lesson_ids")

        # Add quiz score
        quiz_scores = dict(progress.quiz_scores or {})
        quiz_scores[lesson_id] = body.quiz_score
        progress.quiz_scores = quiz_scores
        flag_modified(progress, "quiz_scores")

        # Add XP: 50 base + quiz_score // 10
        xp_earned = 50 + body.quiz_score // 10
        progress.total_xp = (progress.total_xp or 0) + xp_earned

        # Recalculate level and risk score
        progress.current_level = calculate_level(progress.total_xp)
        progress.phishing_risk_score = calculate_risk_score(len(completed_ids))

        # Check badge awards
        progress.badges = check_badge_awards(completed_ids, progress.badges or [])
        flag_modified(progress, "badges")

        # Update streak and last activity date
        today = datetime.utcnow().date()
        if progress.last_activity_date:
            last_date = progress.last_activity_date.date() if hasattr(progress.last_activity_date, "date") else progress.last_activity_date
            delta = (today - last_date).days
            if delta == 1:
                progress.streak_days = (progress.streak_days or 0) + 1
            elif delta > 1:
                progress.streak_days = 1
        else:
            progress.streak_days = 1

        progress.last_activity_date = datetime.utcnow()

    db.commit()

    return _progress_response(progress)
