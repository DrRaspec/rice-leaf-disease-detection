#!/bin/bash
set -euo pipefail

RICE_ENV_PATH="${RICE_ENV_PATH:-$HOME/rice-env}"
source "$RICE_ENV_PATH/bin/activate"
python -c "
import tensorflow as tf
print('TF version:', tf.__version__)
print('Built with CUDA:', tf.test.is_built_with_cuda())
gpus = tf.config.list_physical_devices('GPU')
print('GPU devices:', gpus)
if gpus:
    print('SUCCESS: GPU detected!')
else:
    print('WARNING: No GPU detected')
"
