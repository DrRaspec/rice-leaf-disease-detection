import argparse
import json
import os
import sys
from pathlib import Path

from PIL import Image, UnidentifiedImageError

# Keep stdout clean so Spring can parse JSON reliably.
os.environ.setdefault("TF_CPP_MIN_LOG_LEVEL", "3")
os.environ.setdefault("TF_ENABLE_ONEDNN_OPTS", "0")

try:
    from pillow_heif import register_heif_opener
except Exception:
    register_heif_opener = None

from model.inference import predict_image


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Rice disease prediction CLI")
    parser.add_argument("--image", required=True, help="Path to input image")
    parser.add_argument("--top-k", type=int, default=3, help="Top-k predictions")
    return parser.parse_args()


def main() -> int:
    if register_heif_opener is not None:
        register_heif_opener()

    args = parse_args()
    image_path = Path(args.image)

    if not image_path.exists():
        print(f"Image not found: {image_path}", file=sys.stderr)
        return 2

    try:
        with Image.open(image_path) as image:
            result = predict_image(image, top_k=args.top_k)
    except UnidentifiedImageError:
        print("Invalid image format.", file=sys.stderr)
        return 3
    except Exception as exc:
        print(str(exc), file=sys.stderr)
        return 1

    print(json.dumps(result))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
