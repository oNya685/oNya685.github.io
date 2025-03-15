#!/bin/bash
#
#Backup config, content and static to ./backup/
mkdir -p ./backup/
cp -r hugo.* ./content/ ./static/ ./backup/
