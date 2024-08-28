.PHONY: build
build:
	fpc -g -Fu'vendor/*' highscores

.PHONY: run
run: build
	LOG_LEVEL=DEBUG ./highscores

.PHONY: clean
clean:
	rm -f *.o *.ppu *.res
