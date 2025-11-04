const std = @import("std");
const Allocator = std.mem.Allocator;
const EnumArray = std.enums.EnumArray;

const sdl3 = @import("sdl3");
const log = sdl3.log.Category;

const game = @import("game.zig");
const graphics = @import("graphics/graphics.zig");
const gamestates = @import("gamestates/gamestates.zig");

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

    var game_arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer game_arena.deinit();

    const g: game.Game = .{
        .state = .{ .MainMenu = gamestates.MainMenu{} },
        .dice = .{game.Die{ .x = 0, .y = 0, .r = 0, .value = 0 }} ** 4,
        .payments = .{game.Die{ .x = 0, .y = 0, .r = 0, .value = 0 }} ** 6,
    };

    const sprites = graphics.sprites.init(renderer) catch |err| {
        try sdl3.log.Category.logCritical(
            .application,
            "Failed to load sprites: {}",
            .{err},
        );
        return;
    };

    Gameloop(game_arena.allocator(), renderer, g, sprites) catch {
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

fn Gameloop(game_arena: Allocator, renderer: sdl3.render.Renderer, g: game.Game, sprites: EnumArray(graphics.sprites.Sprite, graphics.sprites.SpriteData)) !void {
    var state = g.state;
    while (state != .Quit) {
        var frameArena = std.heap.ArenaAllocator.init(game_arena);
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
                .key_down => |keyboard| if (keyboard.key) |key| {
                    state = state.keyDown(key);
                },
                .quit => state = .Quit,
                .terminating => state = .Quit,
                else => {},
            };

        state = state.update();

        const draw_objects = state.draw(frameArena.allocator()) catch |err| {
            try log.logError(.application, "Failed to draw state {}: {}", .{ state, err });
            continue;
        };

        for (draw_objects.items) |object| {
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
                    const sprite = sprites.get(t.sprite);

                    renderer.setDrawColor(.{ .r = t.color.r, .g = t.color.g, .b = t.color.b, .a = 255 }) catch {
                        try log.logWarn(.application, "Failed to set color: {?s}", .{sdl3.errors.get()});
                    };

                    renderer.renderTextureRotated(
                        sprite.spritesheet,
                        sprite.rect,
                        switch (t.origin) {
                            .top_left => .{
                                .x = @floatFromInt(t.x),
                                .y = @floatFromInt(t.y),
                                .w = sprite.rect.w,
                                .h = sprite.rect.h,
                            },
                            .center => .{
                                .x = @as(f32, @floatFromInt(t.x)) - sprite.rect.w / 2,
                                .y = @as(f32, @floatFromInt(t.y)) - sprite.rect.h / 2,
                                .w = sprite.rect.w,
                                .h = sprite.rect.h,
                            },
                        },
                        t.r,
                        switch (t.origin) {
                            .top_left => .{ .x = 0, .y = 0 },
                            .center => null,
                        },
                        .{
                            .horizontal = false,
                            .vertical = false,
                        },
                    ) catch {
                        try log.logError(.application, "Failed to draw a texture: {?s}", .{sdl3.errors.get()});
                    };

                    renderer.setDrawColor(white) catch {
                        try log.logWarn(.application, "Failed to set color: {?s}", .{sdl3.errors.get()});
                    };
                },
            }
        }

        renderer.present() catch {
            try log.logWarn(.application, "Failed to present renderer: {?s}", .{sdl3.errors.get()});
        };
    }
}
