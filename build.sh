#!/bin/bash
set -e
set -o pipefail

INSTRUCTION="If you want to deploy, try running the script with 'deploy stage region', e.g. 'deploy dev eu-west-1'"

function tune_function {
  functionName=powertune-lambda-cicd-demo-$2-$3

  echo ""
  echo "$functionName:"
  echo ""
  echo "running 'lumigo-cli powertune-lambda'..."
  lumigo-cli powertune-lambda \
    -r $1 \
    -n $functionName \
    -s $4 \
    -f examples/$3.json \
    -o $3-result.json \
    -z > /dev/null

  optimalPower=`cat $3-result.json | jq -r '.power'`
  echo "optimal power for is $optimalPower MB"

  memorySize=`aws lambda get-function-configuration --region $1 --function-name $functionName | jq -r '.MemorySize'`
  echo "current memory size is $memorySize MB"

  if ((optimalPower != memorySize)); then
    echo "updating function memory size to $optimalPower..."
    aws lambda update-function-configuration \
      --region $1 \
      --function-name $functionName \
      --memory-size $optimalPower > /dev/null
  fi

  echo ""
  echo "-----------------------------"
}

if [ $# -eq 0 ]; then
  echo "No arguments found." 
  echo $INSTRUCTION
  exit 1
elif [ "$1" = "deploy" ] && [ $# -eq 3 ]; then 
  STAGE=$2
  REGION=$3

  npm install

  npm run sls -- deploy -s $STAGE -r $REGION
elif [ "$1" = "tune" ] && [ $# -eq 4 ]; then
  STAGE=$2
  REGION=$3
  STRATEGY=$4
  
  tune_function $REGION $STAGE "cpu-intense" "balanced"
  tune_function $REGION $STAGE "io-intense" "balanced"
  tune_function $REGION $STAGE "mixed" "balanced"

else
  echo $INSTRUCTION
  exit 1
fi