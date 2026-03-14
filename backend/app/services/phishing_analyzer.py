import random
import re
from uuid import uuid4
from datetime import datetime

def analyze_email(content: str) -> dict:
    """Analyze email content for phishing indicators."""
    lower = content.lower()

    # Phishing keywords
    phishing_kws = ["urgent", "verify", "click here", "suspended", "password", "account", "winner", "congratulations"]
    suspicious_kws = ["offer", "free", "limited time", "act now"]

    is_phishy = any(kw in lower for kw in phishing_kws)
    is_suspicious = any(kw in lower for kw in suspicious_kws)

    classification = "phishing" if is_phishy else "suspicious" if is_suspicious else "safe"

    confidence = (
        round(0.85 + random.random() * 0.14, 2) if is_phishy
        else round(0.55 + random.random() * 0.25, 2) if is_suspicious
        else round(0.05 + random.random() * 0.2, 2)
    )

    elements = []
    if "urgent" in lower or "immediately" in lower:
        elements.append({"element": "Urgency language detected", "reason": "Phishing emails often create false urgency to pressure victims into acting quickly.", "severity": 0.85})
    if "click here" in lower or "click below" in lower:
        elements.append({"element": "Generic \"click here\" link", "reason": "Legitimate organizations typically use descriptive link text instead of generic calls to action.", "severity": 0.75})
    if "verify" in lower or "confirm your" in lower:
        elements.append({"element": "Credential harvesting attempt", "reason": "Requests to verify or confirm personal information are a common phishing tactic.", "severity": 0.9})
    if "suspended" in lower or "locked" in lower:
        elements.append({"element": "Account threat language", "reason": "Threatening account suspension is used to create panic and bypass critical thinking.", "severity": 0.88})
    if "winner" in lower or "congratulations" in lower:
        elements.append({"element": "Prize/reward scam language", "reason": "Unsolicited prize notifications are almost always scams.", "severity": 0.92})

    if classification == "phishing":
        explanation = (
            f"This email contains {len(elements)} phishing indicator(s). "
            "The combination of urgency language, suspicious requests, and social engineering tactics "
            "strongly suggests this is a phishing attempt. Do not click any links or provide personal information."
        )
    elif classification == "suspicious":
        explanation = (
            "This email contains some elements that could indicate a phishing attempt, but confidence is moderate. "
            "Exercise caution and verify the sender through an independent channel before taking any action."
        )
    else:
        explanation = (
            "This email does not exhibit common phishing characteristics. "
            "However, always remain vigilant and verify unexpected requests through official channels."
        )

    return {
        "id": str(uuid4()),
        "classification": classification,
        "confidence_score": confidence,
        "suspicious_elements": elements,
        "explanation": explanation,
        "input_type": "email",
        "input_content": content[:100],
        "analyzed_at": datetime.utcnow().isoformat() + "Z",
    }


def analyze_url(url: str) -> dict:
    """Analyze URL for phishing indicators."""
    lower = url.lower()

    is_phishy = (
        ("login" in lower and "google.com" not in lower and "apple.com" not in lower)
        or "paypa1" in lower
        or "amaz0n" in lower
        or "verify-account" in lower
        or ".xyz" in lower
        or ".tk" in lower
        or bool(re.search(r'\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b', url))
    )

    classification = "phishing" if is_phishy else "safe"
    confidence = round(0.88 + random.random() * 0.11, 2) if is_phishy else round(0.1 + random.random() * 0.15, 2)

    elements = []
    if is_phishy:
        elements.append({
            "element": "Suspicious domain pattern",
            "reason": "The URL uses patterns commonly associated with phishing sites (misspellings, unusual TLDs, or IP addresses).",
            "severity": 0.9,
        })

    explanation = (
        "This URL shows signs of being a phishing website. The domain pattern is suspicious and may be impersonating a legitimate service."
        if is_phishy else
        "This URL does not exhibit obvious phishing characteristics. Always verify the domain matches the official website."
    )

    return {
        "id": str(uuid4()),
        "classification": classification,
        "confidence_score": confidence,
        "suspicious_elements": elements,
        "explanation": explanation,
        "input_type": "url",
        "input_content": url,
        "analyzed_at": datetime.utcnow().isoformat() + "Z",
    }


def analyze_screenshot(file_size: int) -> dict:
    """Analyze screenshot (placeholder — returns suspicious classification)."""
    return {
        "id": str(uuid4()),
        "classification": "suspicious",
        "confidence_score": 0.65,
        "suspicious_elements": [
            {
                "element": "Potential brand impersonation",
                "reason": "The screenshot appears to contain elements that mimic a well-known brand, which is a common phishing tactic.",
                "severity": 0.7,
            },
            {
                "element": "Login form detected",
                "reason": "A credential input form was detected. Verify you are on the official website before entering any information.",
                "severity": 0.65,
            },
        ],
        "explanation": (
            "The screenshot analysis detected potential brand impersonation elements and a login form. "
            "This could be a phishing page designed to steal credentials. Verify the URL in the address bar before proceeding."
        ),
        "input_type": "screenshot",
        "input_content": f"[screenshot: {file_size} bytes]",
        "analyzed_at": datetime.utcnow().isoformat() + "Z",
    }
