ZIG=zig

.PHONY: build
build:
	$(ZIG) build

.PHONY: release
release:
	$(ZIG) build -Doptimize=ReleaseFast

.PHONY: run
run: build
	zig-out/bin/wave

.PHONY: debug
debug: build
	SDL_LOGGING=debug gdb zig-out/bin/wave

.PHONY: clean
clean:
