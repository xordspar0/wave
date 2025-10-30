const std = @import("std");
const Allocator = std.mem.Allocator;

const sdl3 = @import("sdl3");
const log = sdl3.log.Category;

const game = @import("game.zig");

pub fn main() !void {
    defer sdl3.shutdown();
    _, const renderer = SDLInit() catch {
        try sdl3.log.Category.logCritical(
            .application,
            "Failed to initialize SDL: {?s}",
            .{sdl3.errors.get()},
        );
        return;
    };

    const g: game.Game = .{
        .state = .MainMenu,
        .dice = .{game.Die{ .x = 0, .y = 0, .r = 0, .value = 0 }} ** 4,
        .payments = .{game.Die{ .x = 0, .y = 0, .r = 0, .value = 0 }} ** 6,
    };
    try log.logInfo(.application, "First die: {d}", .{g.dice[0].value});

    Gameloop(renderer, g) catch {
        try log.logCritical(
            .application,
            "Fatal runtime error: {?s}",
            .{sdl3.errors.get()},
        );
        return;
    };
}

fn SDLInit() !struct { sdl3.video.Window, sdl3.render.Renderer } {
    const compiledVersion = sdl3.Version.compiled_against;
    const linkedVersion = sdl3.Version.get();

    try log.logInfo(.application, "Compiled with SDL {d}.{d}.{d}", .{
        compiledVersion.getMajor(),
        compiledVersion.getMinor(),
        compiledVersion.getMicro(),
    });
    try log.logInfo(.application, "Initializing SDL {d}.{d}.{d}", .{
        linkedVersion.getMajor(),
        linkedVersion.getMinor(),
        linkedVersion.getMicro(),
    });

    try sdl3.setAppMetadata("Wave", "0.1", "xyz.neolog.wave");
    try sdl3.hints.set(sdl3.hints.Type.render_vsync, "1");

    const init_flags = sdl3.InitFlags{ .video = true };
    try sdl3.init(init_flags);
    return sdl3.render.Renderer.initWithWindow("Wave", 640, 480, .{});
}

fn Gameloop(renderer: sdl3.render.Renderer, g: game.Game) !void {
    var gameArena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer gameArena.deinit();

    var state = g.state;
    while (state != .Quit) {
        var frameArena = std.heap.ArenaAllocator.init(gameArena.allocator());
        defer frameArena.deinit();

        const background = sdl3.pixels.Color{ .r = 255, .g = 128, .b = 255, .a = 255 };
        const white = sdl3.pixels.Color{ .r = 255, .g = 255, .b = 255, .a = 255 };

        renderer.setDrawColor(background) catch {
            try log.logWarn(.application, "Failed to set color: {?s}", .{sdl3.errors.get()});
        };
        renderer.clear() catch {
            try log.logWarn(.application, "Failed to clear renderer: {?s}", .{sdl3.errors.get()});
        };

        while (sdl3.events.poll()) |event|
            switch (event) {
                .quit => state = .Quit,
                .terminating => state = .Quit,
                else => {},
            };

        const nextState = state.update();
        defer state = nextState;

        const drawObjects = state.draw(frameArena.allocator()) catch |err| {
            try log.logError(.application, "Failed to draw state {}: {}", .{ state, err });
            continue;
        };

        for (drawObjects.items) |object| {
            switch (object) {
                .FilledRect => |r| {
                    renderer.setDrawColor(.{ .r = r.color.r, .g = r.color.g, .b = r.color.b, .a = 255 }) catch {
                        try log.logWarn(.application, "Failed to set color: {?s}", .{sdl3.errors.get()});
                    };

                    renderer.renderFillRect(.{
                        .x = @floatFromInt(r.x),
                        .y = @floatFromInt(r.y),
                        .w = @floatFromInt(r.w),
                        .h = @floatFromInt(r.h),
                    }) catch {
                        try log.logError(.application, "Failed to draw a rectangle: {?s}", .{sdl3.errors.get()});
                    };

                    renderer.setDrawColor(white) catch {
                        try log.logWarn(.application, "Failed to set color: {?s}", .{sdl3.errors.get()});
                    };
                },
                .Texture => |t| {
                    try log.logInfo(.application, "Found a texture: {}", .{t});
                },
            }
        }

        renderer.present() catch {
            try log.logWarn(.application, "Failed to present renderer: {?s}", .{sdl3.errors.get()});
        };
    }
}
