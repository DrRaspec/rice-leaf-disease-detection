# RiceGuard AI: Rice Leaf Disease Detection

RiceGuard AI helps farmers in Cambodia detect rice leaf diseases from a photo, so they can take faster field action and reduce crop loss.

## Purpose

- Improve early disease detection for rice crops.
- Provide a low-friction scan flow (no farmer login required for prediction).
- Support practical recommendations after classification.

## What This Repo Contains

- `model/`: training and inference code
- `spring-api/`: main backend API (recommended)
- `api/`: optional FastAPI backend
- `web/`: web frontend (Vue)
- `mobile/`: Flutter mobile app
- `dataset/`: training and validation images
- `artifacts/`: generated model files

## Core Flow

1. Train model from `dataset/`
2. Serve prediction endpoint (`POST /api/v1/predict`)
3. Web/mobile upload leaf image and display results

## Quick Start

Use Spring API as primary backend:

1. Install Python dependencies:
```bash
pip install -r requirements.txt
```
2. Train once to generate artifacts:
```bash
python -m model.train
```
3. Set required API env vars:
```bash
set APP_API_USERNAME=riceguard_api_user
set APP_API_PASSWORD=ReplaceWithA_Strong#Password1
set APP_SECURITY_JWT_SECRET=ReplaceWithYourOwnLongRandomSecretAtLeast32Chars
```
4. Run backend:
```bash
cd spring-api
mvn spring-boot:run
```

## Documentation

- Setup and full run instructions: `docs/RUNNING.md`
- Public release safety checklist: `docs/PUBLIC_RELEASE_CHECKLIST.md`
