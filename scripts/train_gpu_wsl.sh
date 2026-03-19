#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RICE_ENV_PATH="${RICE_ENV_PATH:-$HOME/rice-env}"

source "$RICE_ENV_PATH/bin/activate"
cd "$PROJECT_ROOT"
echo "=== Starting GPU Training ==="
echo "Working directory: $(pwd)"
python -m model.train
echo "=== Training Complete ==="
