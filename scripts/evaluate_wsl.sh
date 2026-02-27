#!/bin/bash
source ~/rice-env/bin/activate
cd '/mnt/d/MyProject/python/num/AI Rice Disease Detection System/RiceLeafsDisease'
echo "=== Running Model Evaluation ==="
python -m model.evaluate
echo "=== Evaluation Complete ==="
