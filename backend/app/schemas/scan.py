from pydantic import BaseModel


class AnalyzeRequest(BaseModel):
    type: str  # "email" | "url"
    content: str


class SuspiciousElementOut(BaseModel):
    element: str
    reason: str
    severity: float


class PhishingAnalysisOut(BaseModel):
    id: str
    classification: str
    confidence_score: float
    suspicious_elements: list[SuspiciousElementOut]
    explanation: str
    input_type: str
    input_content: str
    analyzed_at: str
