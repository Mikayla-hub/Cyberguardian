from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.dependencies import get_current_user, get_db
from app.models.user import User
from app.models.progress import UserProgress
from app.schemas.auth import UserResponse
from app.schemas.progress import AwardXpRequest, UserProgressOut
from app.services.progress_service import (
    calculate_level,
    calculate_risk_score,
    check_badge_awards,
)
from sqlalchemy.orm.attributes import flag_modified

router = APIRouter()


def _user_response(user: User) -> UserResponse:
    return UserResponse(
        id=user.id,
        email=user.email,
        display_name=user.display_name,
        role=user.role,
        avatar_url=user.avatar_url,
        biometric_enabled=user.biometric_enabled,
        created_at=user.created_at.isoformat() + "Z" if user.created_at else None,
        last_login_at=user.last_login_at.isoformat() + "Z" if user.last_login_at else None,
    )


def _progress_response(progress: UserProgress) -> UserProgressOut:
    return UserProgressOut(
        user_id=progress.user_id,
        total_xp=progress.total_xp,
        current_level=progress.current_level,
        phishing_risk_score=progress.phishing_risk_score,
        completed_lesson_ids=progress.completed_lesson_ids or [],
        badges=progress.badges or [],
        quiz_scores=progress.quiz_scores or {},
        streak_days=progress.streak_days,
        last_activity_date=progress.last_activity_date.isoformat() + "Z"
        if progress.last_activity_date
        else datetime.utcnow().isoformat() + "Z",
    )


@router.get("/profile", response_model=UserResponse)
def get_profile(current_user: User = Depends(get_current_user)):
    return _user_response(current_user)


@router.get("/progress", response_model=UserProgressOut)
def get_progress(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    progress = (
        db.query(UserProgress)
        .filter(UserProgress.user_id == current_user.id)
        .first()
    )

    if not progress:
        now = datetime.utcnow()
        progress = UserProgress(
            user_id=current_user.id,
            total_xp=0,
            current_level=1,
            phishing_risk_score=1.0,
            completed_lesson_ids=[],
            badges=[],
            quiz_scores={},
            streak_days=0,
            last_activity_date=now,
        )
        db.add(progress)
        db.commit()
        db.refresh(progress)

    return _progress_response(progress)


@router.post("/progress/xp", response_model=UserProgressOut)
def award_xp(
    body: AwardXpRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    progress = (
        db.query(UserProgress)
        .filter(UserProgress.user_id == current_user.id)
        .first()
    )

    if not progress:
        raise HTTPException(status_code=404, detail="User progress not found")

    progress.total_xp += body.amount
    progress.current_level = progress.total_xp // 500 + 1
    completed_ids = progress.completed_lesson_ids or []
    progress.phishing_risk_score = calculate_risk_score(len(completed_ids))
    progress.badges = check_badge_awards(completed_ids, progress.badges or [])
    flag_modified(progress, "badges")
    progress.last_activity_date = datetime.utcnow()

    db.commit()
    db.refresh(progress)

    return _progress_response(progress)
