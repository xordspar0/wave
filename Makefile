.PHONY: build
build:
	fpc -g -Fu'vendor/sdl3/units' wave

.PHONY: release
release:
	fpc -XX -Fu'vendor/sdl3/units' wave

.PHONY: run
run: build
	./wave

.PHONY: debug
debug: build
	SDL_LOGGING=debug gdb --eval-command='b fpc_raiseexception' ./wave

.PHONY: clean
clean:
	rm -f *.o *.ppu *.res
