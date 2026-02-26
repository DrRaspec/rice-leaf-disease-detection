# Running Guide

This guide covers local setup for model training, Spring API, optional FastAPI, web frontend, and mobile app.

## 1) Prerequisites

- Python 3.11
- Java 17+ and Maven (for Spring Boot)
- Node.js 18+ (for web)
- Flutter SDK (for mobile)

Project root:

```bash
cd /d "D:\MyProject\python\num\AI Rice Disease Detection System\RiceLeafsDisease"
```

## 2) Python Setup and Model Training

Install dependencies:

```bash
python -m pip install -r requirements.txt
```

Train model (required at least once):

```bash
python -m model.train
```

Expected generated files:

- `artifacts/rice_disease_model.keras`
- `artifacts/class_names.json`

## 3) Run Spring Boot API (Recommended)

Set required environment variables:

```bash
set APP_API_USERNAME=riceguard_api_user
set APP_API_PASSWORD=ReplaceWithA_Strong#Password1
set APP_SECURITY_JWT_SECRET=ReplaceWithYourOwnLongRandomSecretAtLeast32Chars
```

Start Spring API:

```bash
cd spring-api
mvn spring-boot:run
```

Health check:

- `GET http://127.0.0.1:8080/api/v1/health`

Public prediction endpoint:

- `POST http://127.0.0.1:8080/api/v1/predict` (multipart key: `file`)

Example:

```bash
curl -X POST "http://127.0.0.1:8080/api/v1/predict" ^
  -F "file=@sample.jpg"
```

## 4) Run FastAPI (Optional)

Set required environment variables:

```bash
set APP_API_USERNAME=riceguard_api_user
set APP_API_PASSWORD=ReplaceWithA_Strong#Password1
set APP_SECURITY_JWT_SECRET=ReplaceWithYourOwnLongRandomSecretAtLeast32Chars
```

Start:

```bash
uvicorn api.main:app --reload
```

Health:

- `GET http://127.0.0.1:8000/api/v1/health`

## 5) Run Web App

Create web env file:

```bash
copy web\.env.example web\.env
```

Install and run:

```bash
cd web
npm install
npm run dev
```

Default backend base path is `/api/v1` via `VITE_API_BASE_URL`.

## 6) Run Mobile App

From project root:

```bash
cd mobile
flutter pub get
flutter run --dart-define=ENV=dev --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

Use `10.0.2.2` for Android emulator to reach localhost backend.

## 7) Troubleshooting

- `Class names not found`: run `python -m model.train` to generate `artifacts/class_names.json`.
- `mvn not recognized`: install Maven and reopen terminal.
- `401/403 issues`: verify env vars and restart API process.
- Upload errors: ensure request is multipart form-data with key `file`.
