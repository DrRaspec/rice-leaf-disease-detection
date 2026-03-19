# RiceGuard AI: Rice Leaf Disease Detection

RiceGuard AI detects rice leaf diseases from an image and returns a prediction plus disease guidance in English or Khmer.

## Repository layout

- `model/`: TensorFlow training, evaluation, inference, and CLI prediction
- `api/`: FastAPI backend written in Python
- `spring-api/`: Spring Boot backend that calls the Python inference CLI
- `web/`: Vue 3 frontend
- `mobile/`: Flutter mobile app
- `docs/`: setup and project documentation

## Important before you start

This repository does not include training data or generated model artifacts.

- `dataset/` is gitignored
- `artifacts/` is gitignored

That means prediction only works if you already have one of these:

1. A trained model in `artifacts/rice_disease_model.keras` and `artifacts/class_names.json`
2. A dataset in `dataset/train` and `dataset/validation`, then you run training yourself

If those files are missing, the backends can start but prediction will fail.

## Training on Windows vs GPU

- Windows `py -3.11 -m venv .venv` plus `pip install -r requirements.txt` runs TensorFlow on CPU in this project.
- If you want NVIDIA GPU training on a Windows machine, use WSL2/Linux and install the same `requirements.txt` there.
- Windows local setup is still fine for FastAPI, Spring Boot, the web app, and CPU inference.

## Choose how you want to run it

### Option A: Windows demo or CPU inference

Use this if you want the simplest local setup for inference, the API, or the web demo.

1. Create and activate a Python 3.11 virtual environment
2. Install `requirements.txt`
3. Make sure `artifacts/` exists or train the model elsewhere first
4. Run FastAPI with `python -m uvicorn api.main:app --reload`

Backend URL:

- `http://127.0.0.1:8000/api/v1/health`

### Option B: WSL2 GPU training

Use this if you want to train with an NVIDIA GPU.

1. Open Ubuntu or another Linux distro in WSL2
2. Create and activate a Linux Python 3.11 virtual environment
3. Install `requirements.txt`
4. Run `bash scripts/check_gpu_wsl.sh`
5. Run `bash scripts/train_gpu_wsl.sh`

Generated files:

- `artifacts/rice_disease_model.keras`
- `artifacts/class_names.json`

### Option C: Recommended full stack demo

Use this if you want the main backend and the web app.

1. Set up Python 3.11 and install `requirements.txt`
2. Make sure `artifacts/` exists from an earlier run or WSL2 training
3. Set Spring security environment variables
4. Point Spring to the same Python interpreter used for inference
5. Run `mvn spring-boot:run` in `spring-api/`
6. Run `npm install` and `npm run dev` in `web/`

Backend URL:

- `http://127.0.0.1:8080/api/v1/health`

Web URL:

- `http://localhost:5173`

## Quick start

### 1. GPU training in WSL2

From WSL2:

```bash
cd /mnt/<drive>/MyProject/python/num/RiceLeafsDisease
python3.11 -m venv ~/rice-env
source ~/rice-env/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
bash scripts/check_gpu_wsl.sh
bash scripts/train_gpu_wsl.sh
```

Optional evaluation:

```bash
bash scripts/evaluate_wsl.sh
```

### 2. Windows environment for API, web, or CPU inference

From the project root in PowerShell:

```powershell
py -3.11 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

### 3. Prepare model files

If you already have trained artifacts, place them here:

- `artifacts/rice_disease_model.keras`
- `artifacts/class_names.json`

If you have the dataset instead:

- Use WSL2 and the GPU commands above if you want GPU training
- Use `python -m model.train` only if CPU training is acceptable

### 4. Run the Python backend

Set required environment variables in PowerShell:

```powershell
$env:APP_API_USERNAME="riceguard_api_user"
$env:APP_API_PASSWORD="ReplaceWithA_Strong#Password1"
$env:APP_SECURITY_JWT_SECRET=[Convert]::ToBase64String((1..32 | ForEach-Object { Get-Random -Maximum 256 }))
python -m uvicorn api.main:app --reload
```

### 5. Run the Spring backend

Spring uses Python for inference, so set `APP_PYTHON_COMMAND` to the virtual environment interpreter:

```powershell
$env:APP_API_USERNAME="riceguard_api_user"
$env:APP_API_PASSWORD="ReplaceWithA_Strong#Password1"
$env:APP_SECURITY_JWT_SECRET=[Convert]::ToBase64String((1..32 | ForEach-Object { Get-Random -Maximum 256 }))
$env:APP_PYTHON_COMMAND="$PWD\.venv\Scripts\python.exe"
cd spring-api
mvn spring-boot:run
```

### 6. Run the web app

The Vite dev server already proxies `/api` to `http://localhost:8080`, so no `.env` file is required when using the Spring backend.

```powershell
cd web
npm install
npm run dev
```

If you want the web app to talk to FastAPI on port `8000`, create `web/.env.local` with:

```env
VITE_API_BASE_URL=http://127.0.0.1:8000/api/v1
```

### 7. Run the mobile app

```powershell
cd mobile
flutter pub get
flutter run --dart-define=ENV=dev --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

Use:

- `http://10.0.2.2:8080` for Android emulator to reach your local Spring backend
- Your computer's LAN IP for a real device on the same network

## Useful commands

Train model:

WSL2 GPU:

```bash
bash scripts/train_gpu_wsl.sh
```

Windows CPU:

```powershell
python -m model.train
```

Evaluate model:

WSL2 GPU:

```bash
bash scripts/evaluate_wsl.sh
```

Windows CPU:

```powershell
python -m model.evaluate
```

Predict one image from the command line:

```powershell
python -m model.predict_cli --image path\to\leaf.jpg
```

Check API health:

```powershell
curl.exe http://127.0.0.1:8080/api/v1/health
curl.exe http://127.0.0.1:8000/api/v1/health
```

Test prediction:

```powershell
curl.exe -X POST "http://127.0.0.1:8080/api/v1/predict" -F "file=@sample.jpg"
```

## Documentation

- Full setup and run guide: `docs/RUNNING.md`
- AI pipeline details: `docs/AI_PROCESS_FLOW.md`
- Dataset references: `docs/DATA_SOURCES.md`
- Catalog synchronization notes: `docs/CATALOG_SYNC_WORKFLOW.md`
