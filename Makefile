.PHONY: build
build:
	fpc -g -Fu'vendor/*' highscores

.PHONY: release
release:
	fpc -XX -Fu'vendor/*' highscores

.PHONY: run
run: build
	./highscores

.PHONY: debug
debug: build
	SDL_LOGGING=debug gdb --eval-command='b fpc_raiseexception' ./highscores

.PHONY: clean
clean:
	rm -f *.o *.ppu *.res
