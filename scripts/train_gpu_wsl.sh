#!/bin/bash
source ~/rice-env/bin/activate
cd '/mnt/d/MyProject/python/num/AI Rice Disease Detection System/RiceLeafsDisease'
echo "=== Starting GPU Training ==="
echo "Working directory: $(pwd)"
python -m model.train
echo "=== Training Complete ==="
