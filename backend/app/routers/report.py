import os
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.orm import Session
from app.config import settings
from app.dependencies import get_current_user, get_db
from app.models.report import PhishingReport
from app.models.user import User
from app.services.report_classifier import classify_report

router = APIRouter()


def _report_response(r: PhishingReport) -> dict:
    return {
        "case_id": r.case_id,
        "category": r.category,
        "status": r.status,
        "content_text": r.content_text,
        "url": r.url,
        "screenshot_path": r.screenshot_path,
        "ai_confidence": r.ai_confidence,
        "ai_explanation": r.ai_explanation,
        "submitted_at": r.submitted_at.isoformat() + "Z" if r.submitted_at else "",
        "resolved_at": r.resolved_at.isoformat() + "Z" if r.resolved_at else None,
    }


@router.post("")
async def submit_report(
    request: Request,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    content_type = request.headers.get("content-type", "")

    content_text = ""
    url = None
    screenshot_path = None

    if "multipart" in content_type:
        form = await request.form()
        content_text = form.get("content_text", "")
        url = form.get("url") or None
        screenshot = form.get("screenshot")

        if screenshot is not None:
            file_bytes = await screenshot.read()
            os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
            filename = f"report_{datetime.utcnow().strftime('%Y%m%d%H%M%S')}_{screenshot.filename}"
            filepath = os.path.join(settings.UPLOAD_DIR, filename)
            with open(filepath, "wb") as f:
                f.write(file_bytes)
            screenshot_path = filepath
    else:
        body = await request.json()
        content_text = body.get("content_text", "")
        url = body.get("url") or None

    # Auto-classify the report
    category = classify_report(content_text, url)

    # Generate case_id
    count = (
        db.query(PhishingReport)
        .filter(PhishingReport.user_id == current_user.id)
        .count()
    )
    case_id = f"PG-2026-{count + 1:04d}"

    # Build AI explanation based on category
    explanations = {
        "emailPhishing": "This report has been classified as a phishing email attempt based on the content analysis.",
        "websiteSpoofing": "This report has been classified as website spoofing based on the suspicious URL provided.",
        "smsPhishing": "This report has been classified as SMS phishing (smishing) based on text message indicators.",
        "socialEngineering": "This report has been classified as a social engineering attack based on impersonation indicators.",
    }
    ai_explanation = explanations.get(
        category,
        "This report has been classified based on automated content analysis.",
    )

    report = PhishingReport(
        case_id=case_id,
        user_id=current_user.id,
        category=category,
        status="submitted",
        content_text=content_text,
        url=url,
        screenshot_path=screenshot_path,
        ai_confidence=0.87,
        ai_explanation=ai_explanation,
    )
    db.add(report)
    db.commit()
    db.refresh(report)

    return _report_response(report)


@router.get("")
async def get_reports(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    reports = (
        db.query(PhishingReport)
        .filter(PhishingReport.user_id == current_user.id)
        .order_by(PhishingReport.submitted_at.desc())
        .all()
    )
    return [_report_response(r) for r in reports]


@router.get("/{case_id}")
async def get_report(
    case_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    report = (
        db.query(PhishingReport)
        .filter(PhishingReport.case_id == case_id)
        .first()
    )
    if report is None:
        raise HTTPException(status_code=404, detail="Report not found")
    return _report_response(report)
