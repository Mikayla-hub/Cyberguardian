from pydantic import BaseModel


class ReportCreateRequest(BaseModel):
    content_text: str
    url: str | None = None


class PhishingReportOut(BaseModel):
    case_id: str
    category: str
    status: str
    content_text: str
    url: str | None = None
    screenshot_path: str | None = None
    ai_confidence: float
    ai_explanation: str
    submitted_at: str
    resolved_at: str | None = None
