def classify_report(content: str, url: str | None) -> str:
    """Auto-classify a phishing report based on its content."""
    lower = content.lower()
    if url:
        return "websiteSpoofing"
    if any(kw in lower for kw in ["sms", "text message", "whatsapp"]):
        return "smsPhishing"
    if any(kw in lower for kw in ["call", "impersonat", "pretend"]):
        return "socialEngineering"
    return "emailPhishing"
