from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.orm import Session
from app.dependencies import get_current_user, get_db, get_optional_user
from app.models.scan import PhishingAnalysis
from app.models.user import User
from app.services.phishing_analyzer import analyze_email, analyze_url, analyze_screenshot
from app.schemas.scan import PhishingAnalysisOut
import os
from app.config import settings
from typing import List

router = APIRouter()


def _analysis_response(a: PhishingAnalysis) -> dict:
    return {
        "id": a.id,
        "classification": a.classification,
        "confidence_score": a.confidence_score,
        "suspicious_elements": a.suspicious_elements or [],
        "explanation": a.explanation,
        "input_type": a.input_type,
        "input_content": a.input_content,
        "analyzed_at": a.analyzed_at.isoformat() + "Z" if a.analyzed_at else "",
    }


@router.post("", response_model=PhishingAnalysisOut)
async def analyze(
    request: Request,
    db: Session = Depends(get_db),
    current_user: User | None = Depends(get_optional_user),
):
    content_type = request.headers.get("content-type", "")

    if "multipart" in content_type:
        form = await request.form()
        scan_type = form.get("type", "screenshot")
        file = form.get("file")
        if file is None:
            raise HTTPException(status_code=400, detail="File is required for screenshot analysis")
        file_bytes = await file.read()
        # Analyze first to get the result id, then use it for the filename
        result = analyze_screenshot(len(file_bytes))
        filename = f"scan_{result['id']}.png"
        filepath = os.path.join(settings.UPLOAD_DIR, filename)
        os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
        with open(filepath, "wb") as f:
            f.write(file_bytes)
    else:
        body = await request.json()
        scan_type = body.get("type", "email")
        content = body.get("content", "")
        if scan_type == "url":
            result = analyze_url(content)
        else:
            result = analyze_email(content)

    # Save to database
    analysis = PhishingAnalysis(
        id=result["id"],
        user_id=current_user.id if current_user else None,
        classification=result["classification"],
        confidence_score=result["confidence_score"],
        suspicious_elements=result["suspicious_elements"],
        explanation=result["explanation"],
        input_type=result["input_type"],
        input_content=result["input_content"],
    )
    db.add(analysis)
    db.commit()

    return result


@router.get("/history", response_model=List[PhishingAnalysisOut])
async def get_history(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    analyses = (
        db.query(PhishingAnalysis)
        .filter(PhishingAnalysis.user_id == current_user.id)
        .order_by(PhishingAnalysis.analyzed_at.desc())
        .all()
    )
    return [_analysis_response(a) for a in analyses]
