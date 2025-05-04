#!/bin/bash
#
# rm -rf ./public/ ./content/ ./resources/
# mkdir -p ./content/ 
rsync -av --delete --quiet --exclude='templates/' /home/onya/webdav/Blog/* ./content/ 
chown -R onya: ./content/
