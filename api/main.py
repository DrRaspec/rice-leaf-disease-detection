from io import BytesIO
import os
import secrets
import time

import jwt
from fastapi import FastAPI, File, HTTPException, Request, UploadFile
from fastapi.responses import JSONResponse
from PIL import Image, UnidentifiedImageError
from pydantic import BaseModel

from model.inference import predict_image


app = FastAPI(title="Rice Leaf Disease Detection API", version="1.0.0")

API_USERNAME = os.getenv("APP_API_USERNAME")
API_PASSWORD = os.getenv("APP_API_PASSWORD")
JWT_SECRET = os.getenv("APP_SECURITY_JWT_SECRET")
JWT_ISSUER = os.getenv("APP_JWT_ISSUER", "rice-disease-api")
ACCESS_TOKEN_TTL_SECONDS = int(os.getenv("APP_ACCESS_TOKEN_TTL_SECONDS", "900"))
REFRESH_TOKEN_TTL_SECONDS = int(os.getenv("APP_REFRESH_TOKEN_TTL_SECONDS", "604800"))
RATE_LIMIT_WINDOW_SECONDS = int(os.getenv("APP_RATE_LIMIT_WINDOW_SECONDS", "60"))
RATE_LIMIT_MAX_REQUESTS = int(os.getenv("APP_RATE_LIMIT_MAX_REQUESTS", "60"))
TRUST_X_FORWARDED_FOR = os.getenv("APP_TRUST_X_FORWARDED_FOR", "false").lower() == "true"

_refresh_store: dict[str, tuple[str, int]] = {}
_rate_limit_store: dict[str, tuple[int, int]] = {}
_BANNED_USERNAMES = {"admin", "root", "riceguard"}
_BANNED_PASSWORDS = {"password", "changeme", "changeit", "ChangeThisPassword123!"}
_BANNED_JWT_SECRETS = {
    "ReplaceWithYourOwnLongJwtSecretAtLeast32Chars",
    "secret",
    "changeme",
    "changeit",
}


class LoginRequest(BaseModel):
    username: str
    password: str


class RefreshRequest(BaseModel):
    refreshToken: str


class AuthTokensResponse(BaseModel):
    tokenType: str
    accessToken: str
    expiresInSeconds: int
    refreshToken: str
    refreshExpiresInSeconds: int


@app.on_event("startup")
def validate_security_config() -> None:
    if not API_USERNAME or not API_PASSWORD or not JWT_SECRET:
        raise RuntimeError(
            "APP_API_USERNAME, APP_API_PASSWORD, and APP_SECURITY_JWT_SECRET must be set."
        )
    if API_USERNAME.strip().lower() in _BANNED_USERNAMES:
        raise RuntimeError("APP_API_USERNAME uses an insecure default/common value.")
    if API_PASSWORD.strip() in _BANNED_PASSWORDS:
        raise RuntimeError("APP_API_PASSWORD uses an insecure default/common value.")
    if JWT_SECRET.strip() in _BANNED_JWT_SECRETS or len(JWT_SECRET) < 32:
        raise RuntimeError(
            "APP_SECURITY_JWT_SECRET is insecure. Use a unique random secret with at least 32 characters."
        )


def _unix_now() -> int:
    return int(time.time())


def _create_access_token(username: str, now: int) -> str:
    payload = {
        "iss": JWT_ISSUER,
        "sub": username,
        "type": "access",
        "iat": now,
        "exp": now + ACCESS_TOKEN_TTL_SECONDS,
    }
    return jwt.encode(payload, JWT_SECRET, algorithm="HS256")


def _create_refresh_token(username: str, refresh_id: str, now: int) -> str:
    payload = {
        "iss": JWT_ISSUER,
        "sub": username,
        "jti": refresh_id,
        "type": "refresh",
        "iat": now,
        "exp": now + REFRESH_TOKEN_TTL_SECONDS,
    }
    return jwt.encode(payload, JWT_SECRET, algorithm="HS256")


def _issue_tokens(username: str, now: int) -> AuthTokensResponse:
    refresh_id = secrets.token_urlsafe(32)
    _refresh_store[refresh_id] = (username, now + REFRESH_TOKEN_TTL_SECONDS)
    return AuthTokensResponse(
        tokenType="Bearer",
        accessToken=_create_access_token(username, now),
        expiresInSeconds=ACCESS_TOKEN_TTL_SECONDS,
        refreshToken=_create_refresh_token(username, refresh_id, now),
        refreshExpiresInSeconds=REFRESH_TOKEN_TTL_SECONDS,
    )


def _consume_refresh_token(refresh_id: str, username: str, now: int) -> bool:
    stored = _refresh_store.pop(refresh_id, None)
    if stored is None:
        return False
    stored_username, expires_at = stored
    return stored_username == username and expires_at > now


def _parse_refresh_token(token: str) -> tuple[str, str]:
    try:
        payload = jwt.decode(
            token,
            JWT_SECRET,
            algorithms=["HS256"],
            issuer=JWT_ISSUER,
            options={"require": ["iss", "sub", "exp", "type", "jti"]},
        )
    except jwt.PyJWTError as exc:
        raise HTTPException(status_code=401, detail="Invalid refresh token.") from exc

    if payload.get("type") != "refresh":
        raise HTTPException(status_code=401, detail="Invalid refresh token.")

    username = payload.get("sub")
    refresh_id = payload.get("jti")
    if not isinstance(username, str) or not isinstance(refresh_id, str):
        raise HTTPException(status_code=401, detail="Invalid refresh token.")
    return username, refresh_id


def _client_ip(request: Request) -> str:
    if TRUST_X_FORWARDED_FOR:
        forwarded = request.headers.get("x-forwarded-for")
        if forwarded:
            return forwarded.split(",")[0].strip()
    client = request.client
    return client.host if client else "unknown"


def _cleanup_rate_limit(now: int) -> None:
    stale_before = now - RATE_LIMIT_WINDOW_SECONDS
    stale_keys = [
        key for key, (window_start, _) in _rate_limit_store.items() if window_start < stale_before
    ]
    for key in stale_keys:
        _rate_limit_store.pop(key, None)


@app.middleware("http")
async def rate_limit_middleware(request: Request, call_next):
    if request.method.upper() == "POST" and request.url.path in {
        "/predict",
        "/auth/login",
        "/auth/refresh",
        "/api/v1/predict",
        "/api/v1/auth/login",
        "/api/v1/auth/refresh",
    }:
        now = _unix_now()
        key = f"{_client_ip(request)}:{request.url.path}"
        window_start, count = _rate_limit_store.get(key, (now, 0))
        if now - window_start >= RATE_LIMIT_WINDOW_SECONDS:
            window_start, count = now, 0

        if count >= RATE_LIMIT_MAX_REQUESTS:
            retry_after = max(1, RATE_LIMIT_WINDOW_SECONDS - (now - window_start))
            return JSONResponse(
                status_code=429,
                content={"detail": "Rate limit exceeded. Please retry later."},
                headers={"Retry-After": str(retry_after)},
            )

        _rate_limit_store[key] = (window_start, count + 1)
        if len(_rate_limit_store) > 5000:
            _cleanup_rate_limit(now)

    return await call_next(request)


@app.get("/health")
@app.get("/api/v1/health")
def health_check() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/auth/login", response_model=AuthTokensResponse)
@app.post("/api/v1/auth/login", response_model=AuthTokensResponse)
def login(request: LoginRequest) -> AuthTokensResponse:
    if request.username != API_USERNAME or request.password != API_PASSWORD:
        raise HTTPException(status_code=401, detail="Invalid credentials.")
    return _issue_tokens(request.username, _unix_now())


@app.post("/auth/refresh", response_model=AuthTokensResponse)
@app.post("/api/v1/auth/refresh", response_model=AuthTokensResponse)
def refresh(request: RefreshRequest) -> AuthTokensResponse:
    username, refresh_id = _parse_refresh_token(request.refreshToken)
    now = _unix_now()
    if not _consume_refresh_token(refresh_id, username, now):
        raise HTTPException(status_code=401, detail="Refresh token expired or revoked.")
    return _issue_tokens(username, now)


@app.post("/predict")
@app.post("/api/v1/predict")
async def predict(file: UploadFile = File(...)) -> dict:
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Please upload an image file.")

    content = await file.read()
    if not content:
        raise HTTPException(status_code=400, detail="Empty file uploaded.")

    try:
        image = Image.open(BytesIO(content))
    except UnidentifiedImageError as exc:
        raise HTTPException(status_code=400, detail="Invalid image format.") from exc

    try:
        return predict_image(image)
    except FileNotFoundError as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc
