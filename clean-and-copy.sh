#!/bin/bash
#
rm -rf ./public/ ./content/ 
mkdir -p ./content/ 
rsync -av --quiet --exclude='templates/' /home/onya/webdav/Blog/* ./content/ 
