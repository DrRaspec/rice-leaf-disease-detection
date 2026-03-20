# Running Guide

Get RiceGuard AI running from scratch. This guide covers the full setup path for Python inference, Spring Boot, the web frontend, and the mobile app.

For the model pipeline details, see [AI_PROCESS_FLOW.md](AI_PROCESS_FLOW.md).

---

## Table of Contents

1. [What You Need Before Starting](#1-what-you-need-before-starting)
2. [Project Layout and Important Paths](#2-project-layout-and-important-paths)
3. [Windows Python Setup](#3-windows-python-setup)
4. [Linux or WSL2 Setup for Training](#4-linux-or-wsl2-setup-for-training)
5. [Required Local Assets](#5-required-local-assets)
6. [Sanity Checks Before Running Anything](#6-sanity-checks-before-running-anything)
7. [Run Direct Python Inference](#7-run-direct-python-inference)
8. [Run the Spring Boot Backend](#8-run-the-spring-boot-backend)
9. [Run the Web Frontend](#9-run-the-web-frontend)
10. [Run the Mobile App](#10-run-the-mobile-app)
11. [Train the Model](#11-train-the-model)
12. [Recommended Run Combinations](#12-recommended-run-combinations)
13. [Useful Commands Summary](#13-useful-commands-summary)
14. [Common Problems](#14-common-problems)
15. [Cleanup](#15-cleanup)

---

## 1. What You Need Before Starting

Install only the tools required for the parts you plan to run:

| Tool | Required For | Install |
|------|-------------|---------|
| Python 3.11 | Inference and training | [python.org](https://www.python.org/downloads/) |
| Java 17+ | Spring Boot backend (`spring-api/`) | [adoptium.net](https://adoptium.net/) |
| Maven | Spring Boot backend (`spring-api/`) | [maven.apache.org](https://maven.apache.org/) |
| Node.js 18+ | Web frontend (`web/`) | [nodejs.org](https://nodejs.org/) |
| Flutter SDK | Mobile app (`mobile/`) | [flutter.dev](https://flutter.dev/) |
| WSL2 + Ubuntu | GPU training with NVIDIA | [learn.microsoft.com](https://learn.microsoft.com/en-us/windows/wsl/install) |

### Verify the tools

**Windows PowerShell**

```powershell
py -3.11 --version
java --version
mvn --version
node --version
```

**Linux / WSL2**

```bash
python3.11 --version
node --version
```

> [!WARNING]
> On Windows, do **not** use `python3.11` unless you specifically installed a command with that name.
> Use `py -3.11` or a known Python 3.11 executable.

---

## 2. Project Layout and Important Paths

Open a terminal in the repository root:

```powershell
cd "D:\MyProject\python\num\AI Rice Disease Detection System\RiceLeafsDisease"
```

Important folders:

- `model/` contains Python training and inference code
- `spring-api/` contains the Spring Boot backend
- `web/` contains the Vite frontend
- `mobile/` contains the Flutter app
- `artifacts/` contains trained model files
- `dataset/` contains training images

> [!IMPORTANT]
> The Python package name is `model`, and it lives in the repository root.
> Any command using `python -m model.predict_cli` must run with the repository root available on Python's import path.
> For Spring Boot, the safest approach is to set `APP_PROJECT_ROOT` to the repository root every time.

---

## 3. Windows Python Setup

Use this setup for local inference, training, and Spring Boot on Windows.

### Step 1 - Create the virtual environment

```powershell
cd "D:\MyProject\python\num\AI Rice Disease Detection System\RiceLeafsDisease"
py -3.11 -m venv .venv
```

### Step 2 - Activate it

```powershell
.\.venv\Scripts\Activate.ps1
```

If PowerShell blocks activation, run this once and reopen the terminal:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

### Step 3 - Install dependencies

```powershell
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

### Step 4 - Verify the environment

```powershell
python --version
python -c "import sys; print(sys.executable)"
```

Expected results:

- Python version is `3.11.x`
- Executable points to `...\RiceLeafsDisease\.venv\Scripts\python.exe`

> [!TIP]
> Always keep project packages inside a virtual environment. It avoids conflicts and makes troubleshooting much simpler.

---

## 4. Linux or WSL2 Setup for Training

Use this only if you want Linux-based or GPU-based training.

### Step 1 - Open WSL2 and move into the project

```bash
cd /mnt/d/MyProject/python/num/AI\ Rice\ Disease\ Detection\ System/RiceLeafsDisease
```

### Step 2 - Create and activate a Linux virtual environment

```bash
python3.11 -m venv ~/rice-env
source ~/rice-env/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

### Step 3 - Verify it

```bash
python --version
which python
```

Expected results:

- Python version is `3.11.x`
- Executable points to `~/rice-env/bin/python`

---

## 5. Required Local Assets

This repository does not commit large local assets that are needed for prediction or training.

### Prediction requires

Place these files in `artifacts/`:

- `artifacts/rice_disease_model.keras`
- `artifacts/class_names.json`

### Training requires

Place training data in this structure:

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

If `artifacts/` is missing, prediction endpoints and CLI inference will fail.
If `dataset/` is missing, training will fail.

---

## 6. Sanity Checks Before Running Anything

Run these checks from the repository root after activating the correct Python environment.

### Check 1 - Confirm the `model` package is importable

```powershell
python -c "import model; print(model.__file__)"
```

Expected result:

- A path inside `...\RiceLeafsDisease\model\__init__.py`

### Check 2 - Confirm artifacts exist

```powershell
Get-ChildItem artifacts
```

You should see at least:

- `rice_disease_model.keras`
- `class_names.json`

### Check 3 - Confirm direct CLI help works

```powershell
python -m model.predict_cli --help
```

If this command fails with `No module named 'model'`, you are not running from the repository root or you are using the wrong Python interpreter.

---

## 7. Run Direct Python Inference

This is the fastest way to confirm Python inference works before involving Spring Boot.

### Step 1 - Activate the Windows environment

```powershell
cd "D:\MyProject\python\num\AI Rice Disease Detection System\RiceLeafsDisease"
.\.venv\Scripts\Activate.ps1
```

### Step 2 - Run a prediction from the repository root

```powershell
python -m model.predict_cli --image path\to\leaf.jpg
```

Expected result:

- JSON output printed to the terminal

If this does not work, do not continue to Spring Boot yet. Fix Python inference first.

---

## 8. Run the Spring Boot Backend

Spring Boot does not perform inference directly. It launches a persistent Python worker with `python -m model.predict_worker`.

This means two settings must be correct:

- `APP_PYTHON_COMMAND` must point to the correct Python interpreter
- `APP_PROJECT_ROOT` must point to the repository root so Python can import `model`

The worker keeps the model loaded in memory after startup. That means:

- the first prediction after Spring starts can still be slower because the worker warms up TensorFlow and the model
- later predictions should be much faster because Spring reuses the same Python process

### Step 1 - Open a terminal in the repository root

```powershell
cd "D:\MyProject\python\num\AI Rice Disease Detection System\RiceLeafsDisease"
```

### Step 2 - Activate the Python virtual environment

```powershell
.\.venv\Scripts\Activate.ps1
```

### Step 3 - Set required security environment variables

```powershell
$env:APP_API_USERNAME="riceguard_api_user"
$env:APP_API_PASSWORD="ReplaceWithA_Strong#Password1"
$env:APP_SECURITY_JWT_SECRET=[Convert]::ToBase64String((1..32 | ForEach-Object { Get-Random -Maximum 256 }))
```

### Step 4 - Set the Python interpreter and project root

```powershell
$env:APP_PYTHON_COMMAND="$PWD\.venv\Scripts\python.exe"
$env:APP_PROJECT_ROOT="$PWD"
```

> [!IMPORTANT]
> Treat `APP_PROJECT_ROOT` as required for local Spring runs.
> If Spring launches Python from `spring-api/` or from an IDE with a different working directory, Python may fail with:
> `ModuleNotFoundError: No module named 'model'`

### Step 5 - Verify Python inference before starting Spring

```powershell
& $env:APP_PYTHON_COMMAND -m model.predict_cli --help
```

If this fails, Spring prediction will also fail.

> [!TIP]
> If the first prediction feels slower than the next ones, that is expected with the warm-worker design. The model load happens once during startup/first use instead of on every request.

### Step 6 - Start Spring

```powershell
cd spring-api
mvn spring-boot:run
```

### Step 7 - Verify it is running

Health endpoint:

```text
http://127.0.0.1:8080/api/v1/health
```

Test commands:

```powershell
curl.exe http://127.0.0.1:8080/api/v1/health
curl.exe -X POST "http://127.0.0.1:8080/api/v1/predict" -F "file=@sample.jpg"
```

### Notes

- Max upload size is `6 MB`
- Spring expects multipart form-data with key `file`
- Spring prediction depends on Python dependencies and model artifacts being present
- If you restart the terminal, you must set the environment variables again before launching Spring

---

## 9. Run the Web Frontend

The web app lives in `web/` and uses Vite.

### Default setup with Spring Boot

The Vite dev server proxies `/api` requests to `http://localhost:8080`, so this is the default local setup.

Start Spring first, then run:

```powershell
cd "D:\MyProject\python\num\AI Rice Disease Detection System\RiceLeafsDisease\web"
npm install
npm run dev
```

Open:

```text
http://localhost:5173
```

---

## 10. Run the Mobile App

The mobile app lives in `mobile/`.

### Step 1 - Install packages

```powershell
cd "D:\MyProject\python\num\AI Rice Disease Detection System\RiceLeafsDisease\mobile"
flutter pub get
```

### Step 2 - Choose the backend URL

| Scenario | URL |
|---|---|
| Android emulator to Spring | `http://10.0.2.2:8080` |
| Real device on same network | `http://YOUR_COMPUTER_LAN_IP:8080` |

### Step 3 - Run the app

With Spring backend:

```powershell
flutter run --dart-define=ENV=dev --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

## 11. Train the Model

Run training only if you have the dataset available.

### Step 1 - Confirm dataset folders exist

These directories must exist:

- `dataset/train`
- `dataset/validation`

If you are adding new external datasets first, stop here and follow `docs/DATASET_EXPANSION.md` before retraining.
Do not merge new source folders directly into `dataset/train` or `dataset/validation`.
Use `python scripts/rebuild_dataset_from_sources.py` to rebuild the dataset from the reviewed curated sources.

### Step 2 - Choose your environment

| Environment | Speed | Notes |
|---|---|---|
| Windows `.venv` | CPU only | Simplest local setup |
| WSL2 / Linux | Faster with NVIDIA GPU | Recommended for larger training runs |

### Step 3 - Train

**Windows CPU**

```powershell
cd "D:\MyProject\python\num\AI Rice Disease Detection System\RiceLeafsDisease"
.\.venv\Scripts\Activate.ps1
python -m model.train
```

**WSL2 GPU**

First verify GPU detection:

```bash
bash scripts/check_gpu_wsl.sh
```

Then train:

```bash
bash scripts/train_gpu_wsl.sh
```

Training writes:

- `artifacts/rice_disease_model.keras`
- `artifacts/class_names.json`

### Step 4 - Evaluate

**Windows CPU**

```powershell
python -m model.evaluate
```

**WSL2 GPU**

```bash
bash scripts/evaluate_wsl.sh
```

Evaluation writes:

- `artifacts/confusion_matrix_validation.txt`
- `artifacts/confusion_matrix_validation.png`

See `docs/MODEL_RESULTS.md` for the latest recorded results from the rebuilt dataset.

If you stay on Windows, you can confirm TensorFlow is not seeing a GPU with:

```powershell
python scripts/check_tf_gpu.py
```

---

## 12. Recommended Run Combinations

### Fastest way to test the API

1. Complete Windows Python setup.
2. Confirm `artifacts/` exists.
3. Run direct CLI inference.
4. Run Spring Boot.

### Main local web setup

1. Complete Windows Python setup.
2. Confirm `artifacts/` exists.
3. Set `APP_PYTHON_COMMAND` and `APP_PROJECT_ROOT`.
4. Run Spring Boot.
5. Run the web frontend.

### GPU training plus Windows inference

1. Train in WSL2.
2. Keep inference on Windows with the repository `.venv`.
3. Run Spring Boot from Windows.
4. Run web or mobile against that backend.

---

## 13. Useful Commands Summary

### Windows PowerShell

```powershell
# Go to repo root
cd "D:\MyProject\python\num\AI Rice Disease Detection System\RiceLeafsDisease"

# Create and activate venv
py -3.11 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -r requirements.txt

# Sanity checks
python -c "import model; print(model.__file__)"
python -m model.predict_cli --help

# Direct inference
python -m model.predict_cli --image path\to\leaf.jpg

# Run Spring
$env:APP_API_USERNAME="riceguard_api_user"
$env:APP_API_PASSWORD="ReplaceWithA_Strong#Password1"
$env:APP_SECURITY_JWT_SECRET=[Convert]::ToBase64String((1..32 | ForEach-Object { Get-Random -Maximum 256 }))
$env:APP_PYTHON_COMMAND="$PWD\.venv\Scripts\python.exe"
$env:APP_PROJECT_ROOT="$PWD"
cd spring-api
mvn spring-boot:run

# Run web
cd ..\web
npm install
npm run dev

# Run mobile
cd ..\mobile
flutter pub get
flutter run --dart-define=ENV=dev --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

### Linux / WSL2

```bash
# Enter project
cd /mnt/d/MyProject/python/num/AI\ Rice\ Disease\ Detection\ System/RiceLeafsDisease

# Create and activate venv
python3.11 -m venv ~/rice-env
source ~/rice-env/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt

# Check GPU
bash scripts/check_gpu_wsl.sh

# Train on GPU
bash scripts/train_gpu_wsl.sh

# Evaluate
bash scripts/evaluate_wsl.sh
```

---

## 14. Common Problems

### `ModuleNotFoundError: No module named 'model'`

**Cause:** Python was started without the repository root on its import path. This usually happens when Spring launches Python from `spring-api/` or when the wrong `APP_PROJECT_ROOT` is used.

**Fix:**

1. Open a terminal in the repository root.
2. Activate `.venv`.
3. Set `APP_PYTHON_COMMAND` to the repository `.venv` interpreter.
4. Set `APP_PROJECT_ROOT` to the repository root.
5. Verify `python -m model.predict_cli --help` works before starting Spring.

Example:

```powershell
cd "D:\MyProject\python\num\AI Rice Disease Detection System\RiceLeafsDisease"
.\.venv\Scripts\Activate.ps1
$env:APP_PYTHON_COMMAND="$PWD\.venv\Scripts\python.exe"
$env:APP_PROJECT_ROOT="$PWD"
& $env:APP_PYTHON_COMMAND -m model.predict_cli --help
```

---

### `Model not found` or `Class names not found`

**Cause:** `artifacts/rice_disease_model.keras` or `artifacts/class_names.json` is missing.

**Fix:** Copy existing artifacts into `artifacts/`, or train the model with `python -m model.train`.

---

### `python3.11` is not recognized on Windows

**Cause:** `python3.11` is a Linux naming convention and usually does not exist on Windows.

**Fix:** Use `py -3.11` instead.

---

### `source` is not recognized on Windows

**Cause:** `source` is a bash command, not a PowerShell command.

**Fix:** Use `./.venv/Scripts/Activate.ps1` in PowerShell.

---

### `python` resolves to the wrong interpreter

**Cause:** Another Python installation appears earlier on `PATH`.

**Fix:** Activate the project `.venv`, then verify with:

```powershell
python -c "import sys; print(sys.executable)"
```

---

### `Expected dataset folders` error

**Cause:** `dataset/train` and `dataset/validation` do not exist.

**Fix:** Add the dataset in the expected structure before training.

---

### `mvn` is not recognized

**Cause:** Maven is not installed or not on `PATH`.

**Fix:** Install Maven and reopen the terminal.

---

### Training is using CPU instead of GPU

**Cause:**

- Training is running in Windows instead of WSL2
- TensorFlow GPU support is not available in the Linux environment
- WSL2 GPU support is not configured correctly

**Fix:**

1. Open WSL2.
2. Activate the Linux environment.
3. Run `bash scripts/check_gpu_wsl.sh`.
4. Train with `bash scripts/train_gpu_wsl.sh`.

---

### Spring starts but prediction fails

**Cause:** The Python interpreter is wrong, the project root is wrong, dependencies are missing, or artifacts are missing.

**Fix:**

1. Activate `.venv`.
2. Set `APP_PYTHON_COMMAND`.
3. Set `APP_PROJECT_ROOT`.
4. Confirm `python -m model.predict_cli --help` works.
5. Restart Spring.

---

### PowerShell says script execution is disabled

**Fix:**

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

---

### Web app cannot reach the backend

**Cause:** Spring is not running on `8080`, or the app is pointing at the wrong API base URL.

**Fix:** Start Spring on `8080` and keep the frontend pointed at the Spring backend.

---

### Mobile app cannot reach localhost

**Cause:** Android emulators cannot use plain `localhost` to reach your computer.

**Fix:** Use `http://10.0.2.2:8080`.

---

## 15. Cleanup

When you stop developing and want to reclaim disk space:

### Delete the Windows virtual environment

```powershell
deactivate
Remove-Item -Recurse .\.venv
```

### Delete the Linux / WSL2 virtual environment

```bash
deactivate
rm -rf ~/rice-env
```

### Uninstall globally installed packages if needed

```powershell
py -3.11 -m pip uninstall -r requirements.txt -y
```

> [!TIP]
> Deleting a virtual environment removes all packages installed inside it, which is usually the fastest cleanup path.
