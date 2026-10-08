#!/bin/bash 
cd /mnt/ssd0/inu/CIRCLES
export VLLM_USE_FLASHINFER_SAMPLER=0
export CUDA_VISIBLE_DEVICES=0

MODELS=(
  Qwen/Qwen2.5-VL-7B-Instruct
  Qwen/Qwen2.5-VL-3B-Instruct
  # google/gemma-3-4b-it
  # google/gemma-3-12b-it
)
DATA=waterbirds

for model in "${MODELS[@]}"; do
  tag=${model//\//_}                     # Qwen/Qwen2.5-VL-3B-Instruct → Qwen_Qwen2.5-VL-3B-Instruct
  mkdir -p logs/$DATA/$tag

  python src/run_batch_inference.py --model $model --data $DATA --method circles \
    --k 16 --num_attributes 1 --attribute_k 16 \
    > logs/$DATA/$tag/circles.txt 2>&1
  sleep 30

  python src/run_batch_inference.py --model $model --data $DATA --method none \
    > logs/$DATA/$tag/none.txt 2>&1
  sleep 30

  for m in random rices muier mmices; do
    python src/run_batch_inference.py --model $model --data $DATA --method $m --k 32 \
      > logs/$DATA/$tag/$m.txt 2>&1
    sleep 30
  done
done
