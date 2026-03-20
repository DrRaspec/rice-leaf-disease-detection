import json
import os
import sys
from pathlib import Path

from PIL import Image, UnidentifiedImageError

# Keep stdout reserved for protocol messages.
os.environ.setdefault("TF_CPP_MIN_LOG_LEVEL", "3")
os.environ.setdefault("TF_ENABLE_ONEDNN_OPTS", "0")

try:
    from pillow_heif import register_heif_opener
except Exception:
    register_heif_opener = None

from model.inference import predict_image, warmup_inference_assets


def _emit(payload: dict) -> None:
    sys.stdout.write(json.dumps(payload) + "\n")
    sys.stdout.flush()


def _handle_request(message: dict) -> dict:
    image_path = Path(str(message.get("image_path", "")))
    top_k = int(message.get("top_k", 3))

    if not image_path.exists():
        return {"ok": False, "error": f"Image not found: {image_path}"}

    try:
        with Image.open(image_path) as image:
            result = predict_image(image, top_k=top_k)
        return {"ok": True, "result": result}
    except UnidentifiedImageError:
        return {"ok": False, "error": "Invalid image format."}
    except Exception as exc:
        return {"ok": False, "error": str(exc)}


def main() -> int:
    if register_heif_opener is not None:
        register_heif_opener()

    try:
        warmup_inference_assets()
    except Exception as exc:
        _emit({"ready": False, "error": str(exc)})
        return 1

    _emit({"ready": True})

    for raw_line in sys.stdin:
        line = raw_line.strip()
        if not line:
            continue

        try:
            message = json.loads(line)
        except json.JSONDecodeError:
            _emit({"ok": False, "error": "Invalid worker request JSON."})
            continue

        if message.get("command") == "shutdown":
            _emit({"ok": True, "message": "shutting_down"})
            return 0

        _emit(_handle_request(message))

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
