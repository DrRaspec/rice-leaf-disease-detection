# Running Guide

This guide covers local setup for model training, Spring API, optional FastAPI, web frontend, and mobile app.

For a full technical explanation of the AI pipeline, see `docs/AI_PROCESS_FLOW.md`.

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

### 2.1) GPU Training (Recommended if you have NVIDIA RTX)

TensorFlow GPU on Windows is best supported via WSL2 Ubuntu.

1. In PowerShell (Admin), install WSL2 and Ubuntu:
```powershell
wsl --install -d Ubuntu
```
2. Reboot, open Ubuntu, then in Ubuntu shell:
```bash
sudo apt update
sudo apt install -y python3.11 python3.11-venv python3-pip
cd /mnt/d/MyProject/python/num/AI\ Rice\ Disease\ Detection\ System/RiceLeafsDisease
python3.11 -m venv .venv-linux
source .venv-linux/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```
3. Verify TensorFlow sees GPU:
```bash
python scripts/check_tf_gpu.py
```

If GPUs list is empty, update NVIDIA driver on Windows and run:
```powershell
nvidia-smi
```
before rechecking in WSL.

Train model (required at least once):

```bash
python -m model.train
```

If you changed training code/parameters, retrain from scratch to refresh artifacts:

```bash
python -m model.train
```

Training now uses:

- EfficientNetV2-S backbone (upgraded from EfficientNetB0) with 260×260 input
- Mixup augmentation (α=0.2) with one-hot labels and label smoothing (0.1)
- Deeper classification head (BatchNorm + Dense 256 + Dropout)
- Cosine annealing LR schedule with linear warmup
- Two-phase transfer learning (warm-up + fine-tuning last 60 backbone layers)
- Class weight balancing and top-2 validation metric

Evaluate model quality (recommended after each training run):

```bash
python -m model.evaluate
```

This writes:

- `artifacts/confusion_matrix_validation.txt`
- `artifacts/confusion_matrix_validation.png`

Expected generated files:

- `artifacts/rice_disease_model.keras`
- `artifacts/class_names.json`

## 3) Run Spring Boot API (Recommended)

Set required environment variables:

```cmd
set APP_API_USERNAME=riceguard_api_user
set APP_API_PASSWORD=ReplaceWithA_Strong#Password1
set APP_SECURITY_JWT_SECRET=ReplaceWithYourOwnLongRandomSecretAtLeast32Chars
```

PowerShell equivalent:

```powershell
$env:APP_API_USERNAME="riceguard_api_user"
$env:APP_API_PASSWORD="ReplaceWithA_Strong#Password1"
$env:APP_SECURITY_JWT_SECRET="ReplaceWithYourOwnLongRandomSecretAtLeast32Chars"
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
- Max upload size: `6 MB`

Example:

```bash
curl -X POST "http://127.0.0.1:8080/api/v1/predict" ^
  -F "file=@sample.jpg"
```

## 4) Run FastAPI (Optional)

Set required environment variables:

```cmd
set APP_API_USERNAME=riceguard_api_user
set APP_API_PASSWORD=ReplaceWithA_Strong#Password1
set APP_SECURITY_JWT_SECRET=ReplaceWithYourOwnLongRandomSecretAtLeast32Chars
```

PowerShell equivalent:

```powershell
$env:APP_API_USERNAME="riceguard_api_user"
$env:APP_API_PASSWORD="ReplaceWithA_Strong#Password1"
$env:APP_SECURITY_JWT_SECRET="ReplaceWithYourOwnLongRandomSecretAtLeast32Chars"
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

Note:

- Web and mobile now optimize large images before upload to improve speed on slow networks.
- Mobile converts uploads to JPEG for broad backend compatibility (including HEIC source images).

## 7) Troubleshooting

- `Class names not found`: run `python -m model.train` to generate `artifacts/class_names.json`.
- `mvn not recognized`: install Maven and reopen terminal.
- `401/403 issues`: verify env vars and restart API process.
- Upload errors: ensure request is multipart form-data with key `file`.
