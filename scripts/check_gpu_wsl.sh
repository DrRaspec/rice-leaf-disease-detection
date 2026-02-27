#!/bin/bash
source ~/rice-env/bin/activate
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
