#!/bin/bash

#split checkpoint along the tensor

LOAD_CHECKPOINT_PATH=$1
#<Specify the loaded ckpt path>
SAVE_CHECKPOINT_PATH=$2
#<Specify the stored ckpt path>
TOKENIZER_MODEL_PATH=$3
#<Specify tokenizer model path>
export CUDA_DEVICE_MAX_CONNECTIONS=1

if [ ! -d $SAVE_CHECKPOINT_PATH ]; then

        mkdir $SAVE_CHECKPOINT_PATH

fi

python tools/split_tp_partitions.py \
    --tokenizer-model-path $TOKENIZER_MODEL_PATH \
    --tensor-model-parallel-size 1 \
    --pipeline-model-parallel-size 8 \
    --target-pipeline-model-parallel-size 8 \
    --target-tensor-model-parallel-size 4 \
    --pipeline-generate-layer 0,1,2,3,4,5,6,7 \
    --tokenizer-type YuanTokenizer \
    --num-layers 24 \
    --target-num-layers 24 \
    --hidden-size 2048 \
    --num-attention-heads 16 \
    --kv-channels 256 \
    --seq-length 4096 \
    --max-position-embeddings 4096 \
    --use-lf-gate \
    --lf-conv2d-group 1 \
    --lf-conv2d-num-pad 1 \
    --position-embedding-type rope \
    --flash-attn-drop 0.1 \
    --fim-rate 0.5 \
    --fim-spm-rate 0.5 \
    --attention-dropout 0 \
    --hidden-dropout 0 \
    --norm-dtype RMSNorm \
    --disable-bias-linear \
    --reset-position-ids \
    --use-flash-attn \
    --swiglu \
    --adam-beta1 0.9 \
    --adam-beta2 0.95 \
    --bf16 \
    --num-attention-router-heads 4096 \
    --rotary-percent 0.5 \
    --use-attention-router \
    --no-masked-softmax-fusion \
    --use-fp32-router \
    --num-experts 32 \
    --moe-router-load-balancing-type none \
    --moe-router-topk 2 \
    --moe-grouped-gemm \
    --save-interval 1 \
    --recompute-method block \
    --recompute-granularity full \
    --recompute-num-layers 1 \
    --load $LOAD_CHECKPOINT_PATH \
    --save $SAVE_CHECKPOINT_PATH \
    --micro-batch-size 1 \
    --global-batch-size 1152 \
    --use-distributed-optimizer \
    --lr 0.00009 \
    --train-iters 63578 \
    --lr-decay-iters 63578 \
    --lr-decay-style cosine \
    --min-lr 1.0e-5 \
    --weight-decay 1e-1 \
    --no-load-optim \
    --use-cpu-initialization \
    --process-checkpoint \
    --data-impl mmap --DDP-impl local


du -sh $SAVE_CHECKPOINT_PATH
                                    
