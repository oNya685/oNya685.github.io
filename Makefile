build: clean copy
	hugo

debug: clean copy
	hugo server --bind "0.0.0.0" --port 20003 -D

clean:
	rm -rf ./public/ ./content/

copy:
	mkdir -p ./content/
	rsync -av --quiet --exclude='templates/' /home/onya/webdav/Blog/* ./content/

push: build
	./auto-push.sh

backup:
	./backup.sh

.PHONY: backup
