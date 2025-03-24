#!/bin/bash

set -e

# Arguments
# $1: Hugging Face API Token
# $2: Model ID
# $3: Deploy Type
# $4: Nginx Port 
# $5: Optional - caas

hf_api_token=$1
model_id=$2
deploy_type=$3

if [ "$4" != "" -a "$4" != '80' ]; then
    export NGINX_PORT=$4
fi 

export host_ip=${{secrets.HOST_IP}}
export HUGGINGFACEHUB_API_TOKEN=${{secrets.HUGGINGFACEHUB_API_TOKEN}}
export no_proxy=${{secrets.HOST_IP}},127.0.0.1,localhost,.intel.com,chatqna-xeon-ui-server,chatqna-xeon-backend-server,dataprep-redis-service,tei-embedding-service,retriever,tei-reranking-service,tgi-service,vllm_service

file="docsum/docker_compose/intel/cpu/xeon/compose.yaml"

env_folder_path="docsum/docker_compose/intel/cpu/xeon"

if [[ "$deploy_type" == 'gpu' ]]; then
    env_folder_path="docsum/docker_compose/nvidia/gpu"
    file="docsum/docker_compose/nvidia/gpu/compose.yaml"
    echo "Deploying on GPU"
    echo "Config file: $file"
else
    echo "Deploying on CPU"
    echo "Config file: $file"
fi

# Check if the environment folder path exists
if [ ! -d "$env_folder_path" ]; then
    echo "Environment folder path $env_folder_path does not exist"
    exit 1
fi

# Set Environment Variables
pushd $env_folder_path > /dev/null
if [ -f set_env.sh ]; then
    chmod +x set_env.sh
    source set_env.sh
else
    echo "set_env.sh not found or not executable"
    exit 1
fi
popd > /dev/null


if [[ -n "$model_id" ]]; then
    export LLM_MODEL_ID=${model_id}
fi

echo "===================="
echo "Environment Variables:"
printenv
echo "===================="

# Start Docker Containers
docker compose -f $file up -d