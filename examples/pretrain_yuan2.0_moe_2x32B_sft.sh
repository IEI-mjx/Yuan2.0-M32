#!/bin/bash

# Runs the "Yuan-2.1B" parameter model

export CUDA_DEVICE_MAX_CONNECTIONS=1

GPUS_PER_NODE=8
# Change for multinode config
MASTER_ADDR=localhost
MASTER_PORT=6000
NNODES=1
NODE_RANK=0
WORLD_SIZE=$(($GPUS_PER_NODE*$NNODES))

CHECKPOINT_PATH=<Specify path>
DATA_PATH=<Specify path and file prefix>_text_document
TOKENIZER_MODEL_PATH=<Specify path to file>
TENSORBOARD_PATH=<Specify path to file>

DISTRIBUTED_ARGS="
    --nproc_per_node $GPUS_PER_NODE \
    --nnodes $NNODES \
    --node_rank $NODE_RANK \
    --master_addr $MASTER_ADDR \
    --master_port $MASTER_PORT
"

GPT_ARGS="
    --tensor-model-parallel-size 1 \
    --pipeline-model-parallel-size 8 \
    --timing-log-level 2 \
    --num-workers 2 \
    --num-layers 24 \
    --hidden-size 2048 \
    --num-attention-heads 16 \
    --kv-channels 256 \
    --use-lf-gate \
    --lf-conv2d-group 1 \
    --lf-conv2d-num-pad 1 \
    --rotary-base 40890 \
    --position-embedding-type rope \
    --no-embedding-dropout \
    --flash-attn-drop 0.1 \
    --fim-rate 0.0 \
    --fim-spm-rate 0.0 \
    --norm-dtype RMSNorm \
    --attention-dropout 0 \
    --hidden-dropout 0 \
    --disable-bias-linear \
    --reset-position-ids \
    --use-flash-attn \
    --swiglu \
    --use-distributed-optimizer \
    --adam-beta1 0.9 \
    --adam-beta2 0.95 \
    --seq-length 16384 \
    --max-position-embeddings 16384 \
    --micro-batch-size 1 \
    --global-batch-size 1152 \
    --lr 8.0e-5 \
    --train-iters 4220 \
    --lr-decay-style constant \
    --min-lr 8.0e-5 \
    --weight-decay 1e-1 \
    --clip-grad 1.0 \
    --recompute-method uniform \
    --recompute-granularity full \
    --recompute-num-layers 1 \
    --bf16 \
    --rotary-percent 0.5 \
    --use-attention-router \
    --num-attention-router-heads 16384 \
    --num-experts 32 \
    --no-masked-softmax-fusion \
    --use-fp32-router \
    --moe-router-load-balancing-type none \
    --moe-router-topk 2 \
    --moe-grouped-gemm \ 
    --sft-stage \
    --override-opt-param-scheduler \
    --train-reset \
"


DATA_ARGS="
    --data-path $DATA_PATH \
    --tokenizer-type YuanTokenizer \
    --tokenizer-model-path $TOKENIZER_MODEL_PATH \
    --data-impl mmap \
    --split 10,0,0
"

OUTPUT_ARGS="
    --log-interval 1 \
    --save-interval 10000 \
    --eval-interval 1000000 \
    --eval-iters 10
"

LOG_ARGS="
    --tensorboard-dir $TENSORBOARD_PATH \
    --tensorboard-log-interval 1 \
    --tensorboard-queue-size 1000 \
    --log-timers-to-tensorboard \
    --log-batch-size-to-tensorboard \
    --log-memory-to-tensorboard \
    --log-world-size-to-tensorboard
"

torchrun $DISTRIBUTED_ARGS pretrain_yuan.py \
    $GPT_ARGS \
    $DATA_ARGS \
    $OUTPUT_ARGS \
    $LOG_ARGS \
    --distributed-backend nccl \
    --save $CHECKPOINT_PATH \
    --load $CHECKPOINT_PATH

