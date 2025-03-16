#!/bin/bash
#
rm -rf ./public/ ./content/ ./resources/
mkdir -p ./content/ 
rsync -av --quiet --exclude='templates/' /home/onya/webdav/Blog/* ./content/ 
