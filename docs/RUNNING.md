# Running Guide

This guide explains how to run the project locally, starting with the simplest Python-only path and then covering training, Spring Boot, web, and mobile.

For the model pipeline details, see `docs/AI_PROCESS_FLOW.md`.

## 1. What you need before running anything

Install these tools if you plan to use the matching part of the project:

- Python 3.11 for model training, FastAPI, and Python inference used by Spring
- Java 17+ and Maven for `spring-api/`
- Node.js 18+ for `web/`
- Flutter SDK for `mobile/`

Open a terminal in the project root:

```powershell
cd "D:\MyProject\python\num\AI Rice Disease Detection System\RiceLeafsDisease"
```

## 2. Understand the missing local assets

This repository intentionally does not commit:

- `dataset/`
- `artifacts/`

Those are ignored by Git. Prediction requires model artifacts, so you must have one of the following:

1. Existing artifacts:
   - `artifacts/rice_disease_model.keras`
   - `artifacts/class_names.json`
2. A training dataset so you can generate the artifacts yourself

Training expects this folder structure:

```text
dataset/
  train/
    class_a/
    class_b/
    ...
  validation/
    class_a/
    class_b/
    ...
```

If `artifacts/` is missing, `/predict` will fail with a model or class-names error.

## 3. Python setup

Create and activate a virtual environment from the project root.

### PowerShell on Windows

```powershell
py -3.11 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

If PowerShell blocks activation, run this once in a PowerShell window:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

### Verify Python version

```powershell
python --version
```

You should see Python `3.11.x`.

## 4. Fastest way to run: Python backend only

This is the simplest working backend and the best choice if you only want to test the API.

### Step 1: make sure artifacts exist

You need:

- `artifacts/rice_disease_model.keras`
- `artifacts/class_names.json`

If you do not have them yet, go to section 5 and train the model first.

### Step 2: set required environment variables

Both backends validate these at startup even though prediction itself is public.

```powershell
$env:APP_API_USERNAME="riceguard_api_user"
$env:APP_API_PASSWORD="ReplaceWithA_Strong#Password1"
$env:APP_SECURITY_JWT_SECRET=[Convert]::ToBase64String((1..32 | ForEach-Object { Get-Random -Maximum 256 }))
```

### Step 3: start FastAPI

```powershell
python -m uvicorn api.main:app --reload
```

### Step 4: verify it is running

Health endpoint:

```text
http://127.0.0.1:8000/api/v1/health
```

PowerShell test:

```powershell
curl.exe http://127.0.0.1:8000/api/v1/health
```

Prediction test:

```powershell
curl.exe -X POST "http://127.0.0.1:8000/api/v1/predict" -F "file=@sample.jpg"
```

### Step 5: optional direct CLI prediction

This bypasses the API and tests Python inference directly:

```powershell
python -m model.predict_cli --image path\to\leaf.jpg
```

## 5. Train the model

Run training only if you have the dataset available.

### Step 1: confirm dataset folders exist

These directories must exist:

- `dataset/train`
- `dataset/validation`

### Step 2: train

```powershell
python -m model.train
```

Training writes:

- `artifacts/rice_disease_model.keras`
- `artifacts/class_names.json`

### Step 3: evaluate

```powershell
python -m model.evaluate
```

Evaluation writes:

- `artifacts/confusion_matrix_validation.txt`
- `artifacts/confusion_matrix_validation.png`

### Optional: GPU training

TensorFlow GPU support is typically easier through WSL2 on Windows.

Basic check:

```powershell
python scripts/check_tf_gpu.py
```

If you train in WSL2, create a separate Linux virtual environment there and install the same `requirements.txt`.

## 6. Run the Spring Boot backend

Use Spring if you want the main backend used by the web app. Spring does not run the model itself; it launches the Python CLI in `model.predict_cli`.

### Step 1: activate the Python virtual environment

If not already active:

```powershell
.\.venv\Scripts\Activate.ps1
```

### Step 2: set required environment variables

```powershell
$env:APP_API_USERNAME="riceguard_api_user"
$env:APP_API_PASSWORD="ReplaceWithA_Strong#Password1"
$env:APP_SECURITY_JWT_SECRET=[Convert]::ToBase64String((1..32 | ForEach-Object { Get-Random -Maximum 256 }))
```

### Step 3: point Spring to the correct Python interpreter

This is important. If you skip it, Spring may use the wrong Python installation.

```powershell
$env:APP_PYTHON_COMMAND="$PWD\.venv\Scripts\python.exe"
```

Optional override if Spring cannot resolve the project root:

```powershell
$env:APP_PROJECT_ROOT="$PWD"
```

### Step 4: start Spring

```powershell
cd spring-api
mvn spring-boot:run
```

### Step 5: verify it is running

Health endpoint:

```text
http://127.0.0.1:8080/api/v1/health
```

PowerShell test:

```powershell
curl.exe http://127.0.0.1:8080/api/v1/health
```

Prediction test:

```powershell
curl.exe -X POST "http://127.0.0.1:8080/api/v1/predict" -F "file=@sample.jpg"
```

### Notes

- Max upload size is `6 MB`
- Spring expects multipart form-data with key `file`
- Spring will fail prediction if Python dependencies or model artifacts are missing

## 7. Run the web frontend

The web app is in `web/` and uses Vite.

### Default behavior

The Vite dev server proxies `/api` requests to:

```text
http://localhost:8080
```

That means the web app works out of the box with the Spring backend on port `8080`.

### Run against Spring backend

Start Spring first, then run:

```powershell
cd web
npm install
npm run dev
```

Open:

```text
http://localhost:5173
```

### Run against FastAPI instead

If you want the web app to call FastAPI on port `8000`, create `web/.env.local` with:

```env
VITE_API_BASE_URL=http://127.0.0.1:8000/api/v1
```

Then run:

```powershell
cd web
npm install
npm run dev
```

## 8. Run the mobile app

The mobile app is in `mobile/`.

### Step 1: install packages

```powershell
cd mobile
flutter pub get
```

### Step 2: choose backend URL

Use one of these:

- Android emulator + Spring: `http://10.0.2.2:8080`
- Android emulator + FastAPI: `http://10.0.2.2:8000`
- Real device: `http://YOUR_COMPUTER_LAN_IP:8080` or `:8000`

### Step 3: run

Example with Spring backend:

```powershell
flutter run --dart-define=ENV=dev --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

Example with FastAPI backend:

```powershell
flutter run --dart-define=ENV=dev --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

## 9. Recommended run combinations

### Easiest local API test

1. Set up Python
2. Make sure artifacts exist
3. Run FastAPI

### Main local web setup

1. Set up Python
2. Make sure artifacts exist
3. Run Spring
4. Run the web app

### Full development setup

1. Set up Python
2. Train or copy model artifacts
3. Run Spring or FastAPI
4. Run web or mobile client

## 10. Common problems

### `Model not found` or `Class names not found`

Cause:

- `artifacts/rice_disease_model.keras` or `artifacts/class_names.json` is missing

Fix:

- Copy existing artifacts into `artifacts/`, or
- Train the model with `python -m model.train`

### `Expected dataset folders` error

Cause:

- `dataset/train` and `dataset/validation` do not exist

Fix:

- Add the dataset in the expected structure before training

### `mvn` not recognized

Cause:

- Maven is not installed or not on `PATH`

Fix:

- Install Maven and reopen the terminal

### Spring starts but prediction fails

Cause:

- Spring is using the wrong Python interpreter
- Python dependencies are not installed in that interpreter
- Artifacts are missing

Fix:

1. Activate `.venv`
2. Set `APP_PYTHON_COMMAND` to `.venv\Scripts\python.exe`
3. Confirm `python -m model.predict_cli --image ...` works directly
4. Restart Spring

### PowerShell says script execution is disabled

Fix:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

### Web app cannot reach the backend

Cause:

- Spring is not running on `8080`
- You are using FastAPI but did not set `VITE_API_BASE_URL`

Fix:

- Use Spring on `8080`, or
- Create `web/.env.local` with `VITE_API_BASE_URL=http://127.0.0.1:8000/api/v1`

### Mobile app cannot reach localhost

Cause:

- Android emulator cannot use plain `localhost` to reach your computer

Fix:

- Use `http://10.0.2.2:8080` or `http://10.0.2.2:8000`

## 11. Useful commands summary

Create venv and install dependencies:

```powershell
py -3.11 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

Train:

```powershell
python -m model.train
```

Evaluate:

```powershell
python -m model.evaluate
```

Run FastAPI:

```powershell
python -m uvicorn api.main:app --reload
```

Run Spring:

```powershell
$env:APP_PYTHON_COMMAND="$PWD\.venv\Scripts\python.exe"
cd spring-api
mvn spring-boot:run
```

Run web:

```powershell
cd web
npm install
npm run dev
```

Run mobile:

```powershell
cd mobile
flutter pub get
flutter run --dart-define=ENV=dev --dart-define=API_BASE_URL=http://10.0.2.2:8080
```
