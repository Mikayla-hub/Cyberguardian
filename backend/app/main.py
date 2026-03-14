import os
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.config import settings
from app.database import init_db
from app.routers import auth, incident, lessons, report, scan, user
from app.seed import seed_data


@asynccontextmanager
async def lifespan(app: FastAPI):
    init_db()
    seed_data()
    yield


app = FastAPI(
    title="PhishGuard AI API",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=settings.UPLOAD_DIR), name="uploads")

app.include_router(auth.router, prefix="/auth", tags=["Auth"])
app.include_router(user.router, prefix="/user", tags=["User"])
app.include_router(scan.router, prefix="/analyze", tags=["Scan"])
app.include_router(lessons.router, prefix="/lessons", tags=["Lessons"])
app.include_router(report.router, prefix="/report", tags=["Report"])
app.include_router(incident.router, prefix="/incident-response", tags=["Incident"])


@app.get("/health")
def health_check():
    return {"status": "ok", "service": "PhishGuard AI API"}
