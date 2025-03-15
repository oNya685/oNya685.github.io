#!/bin/bash
#
./build.sh

mkdir -p ./content/

if [ -z "$(git status --porcelain)" ]; then
    echo "没有文件变更可提交"
    exit 0
fi

git add .

commit_time=$(date +"%Y-%m-%d %H:%M:%S")
commit_message="$commit_time"$'\n\n'"$(git status)"

git commit -m "$commit_message" && git push origin main
