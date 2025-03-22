#!/bin/bash
#
# rm -rf ./public/ ./content/ ./resources/
# mkdir -p ./content/ 
rsync -av --delete --quiet --exclude='templates/' /home/onya/webdav/Blog/* ./content/ 
rsync -av --delete --quiet --exclude='templates/' "$SRC_DIR/" "$DEST_DIR"
chown -R onya: ./content/