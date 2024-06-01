.PHONY: build
build:
	fpc -g -Fu~/src/SDL2-for-Pascal/units highscores

.PHONY: run
run: build
	LOG_LEVEL=DEBUG ./highscores

.PHONY: clean
clean:
	rm -f *.o *.ppu *.res
