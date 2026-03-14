from datetime import datetime, timedelta


def calculate_level(total_xp: int) -> int:
    return total_xp // 500 + 1


def calculate_risk_score(completed_count: int) -> float:
    return max(0.1, round(1.0 - completed_count * 0.15, 2))


def check_badge_awards(completed_lesson_ids: list[str], existing_badges: list[dict]) -> list[dict]:
    """Award badges based on completed lessons. Returns updated badge list."""
    badges = list(existing_badges)
    existing_ids = {b["id"] for b in badges}

    if len(completed_lesson_ids) >= 3 and "badge_001" not in existing_ids:
        badges.append({
            "id": "badge_001",
            "name": "Quick Learner",
            "description": "Completed 3 lessons",
            "icon_url": "",
            "earned_at": datetime.utcnow().isoformat() + "Z",
        })

    if len(completed_lesson_ids) >= 5 and "badge_002" not in existing_ids:
        badges.append({
            "id": "badge_002",
            "name": "Phishing Expert",
            "description": "Completed all 5 lessons",
            "icon_url": "",
            "earned_at": datetime.utcnow().isoformat() + "Z",
        })

    return badges


def update_streak(last_activity: datetime | None) -> int:
    """Calculate streak days. Returns new streak count."""
    if last_activity is None:
        return 1
    delta = datetime.utcnow() - last_activity
    if delta < timedelta(days=1):
        return 1  # Same day, no change needed (caller should keep existing)
    if delta < timedelta(days=2):
        return -1  # Signal to increment
    return 0  # Reset streak
