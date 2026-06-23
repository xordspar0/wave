const std = @import("std");
const Allocator = std.mem.Allocator;
const EnumArray = std.enums.EnumArray;

const sdl3 = @import("sdl3");
const log = sdl3.log.Category;

const game = @import("game.zig");
const graphics = @import("graphics/graphics.zig");
const gamestates = @import("gamestates/gamestates.zig");

const screen_width = 640;
const screen_height = 480;

pub fn main(init: std.process.Init) !void {
    defer sdl3.shutdown();
    const window, const renderer = SDLInit() catch {
        try sdl3.log.Category.logCritical(
            .application,
            "Failed to initialize SDL: {?s}",
            .{sdl3.errors.get()},
        );
        return;
    };

    const font = graphics.font.init(renderer) catch {
        try log.logCritical(
            .application,
            "Failed to load font: {?s}",
            .{sdl3.errors.get()},
        );
        return;
    };
    const sprites = graphics.sprites.init(renderer) catch {
        try log.logCritical(
            .application,
            "Failed to load sprites: {?s}",
            .{sdl3.errors.get()},
        );
        return;
    };

    Gameloop(
        init.arena.allocator(),
        init.io,
        window,
        renderer,
        .{ .MainMenu = .{} },
        font,
        sprites,
    ) catch {
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

    try sdl3.init(sdl3.InitFlags{ .video = true });

    const window, const renderer = try sdl3.render.Renderer.initWithWindow("Wave", screen_width, screen_height, .{ .high_pixel_density = true });
    try renderer.setLogicalPresentation(screen_width, screen_height, .letter_box);
    try renderer.setDefaultTextureScaleMode(.pixel_art);

    return .{ window, renderer };
}

fn Gameloop(
    game_arena: Allocator,
    io: std.Io,
    window: sdl3.video.Window,
    renderer: sdl3.render.Renderer,
    initial_state: gamestates.State,
    font: graphics.font.Font,
    sprites: EnumArray(graphics.sprites.Sprite, graphics.sprites.SpriteData),
) !void {
    var state = initial_state;
    var video_state: struct {
        fullscreen: bool = false,
    } = .{};

    const screen_buffer = window_sized_texture: {
        const format = try window.getPixelFormat();
        const width, const height = try window.getSize();

        break :window_sized_texture try renderer.createTexture(format, .target, width, height);
    };
    defer screen_buffer.deinit();

    while (state != .Quit) {
        var frame_arena = std.heap.ArenaAllocator.init(game_arena);
        defer frame_arena.deinit();

        while (sdl3.events.poll()) |event|
            switch (event) {
                .key_down => |keyboard| if (keyboard.key) |key| {
                    switch (key) {
                        .func11 => {
                            video_state.fullscreen = !video_state.fullscreen;
                            window.setFullscreen(video_state.fullscreen) catch {
                                video_state.fullscreen = !video_state.fullscreen;
                                try log.logError(.application, "Failed to set fullscreen mode: {?s}", .{sdl3.errors.get()});
                            };
                        },
                        else => state = state.keyDown(key, io),
                    }
                },
                .mouse_button_down => |mouse_button| {
                    state = state.mouseButtonDown(@trunc(mouse_button.x), @trunc(mouse_button.y));
                },
                .quit => state = .Quit,
                .terminating => state = .Quit,
                else => {},
            };

        state = state.update();

        renderer.setTarget(screen_buffer) catch {
            try log.logWarn(.application, "Failed to set render target to offscreen buffer: {?s}", .{sdl3.errors.get()});
        };

        const white = sdl3.pixels.Color{ .r = 255, .g = 255, .b = 255, .a = 255 };
        const black = sdl3.pixels.Color{ .r = 0, .g = 0, .b = 0, .a = 255 };

        renderer.setDrawColor(black) catch {
            try log.logWarn(.application, "Failed to set color: {?s}", .{sdl3.errors.get()});
        };
        renderer.clear() catch {
            try log.logWarn(.application, "Failed to clear screen buffer: {?s}", .{sdl3.errors.get()});
        };

        const draw_objects = state.draw(frame_arena.allocator()) catch |err| {
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
                        .x = r.x,
                        .y = r.y,
                        .w = r.w,
                        .h = r.h,
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
                                .x = t.x,
                                .y = t.y,
                                .w = sprite.rect.w,
                                .h = sprite.rect.h,
                            },
                            .center => .{
                                .x = t.x - sprite.rect.w / 2,
                                .y = t.y - sprite.rect.h / 2,
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
                .Text => |t| {
                    for (t.text, 0..) |char, i| {
                        const srcRect = font.getChar(char);

                        renderer.renderTexture(
                            font.spritesheet,
                            srcRect,
                            .{
                                .x = t.x + @as(f32, @floatFromInt(i)) * (srcRect.w + 2),
                                .y = t.y,
                                .w = srcRect.w,
                                .h = srcRect.h,
                            },
                        ) catch {
                            try log.logError(.application, "Failed to draw a texture: {?s}", .{sdl3.errors.get()});
                        };
                    }
                },
            }
        }

        renderer.setTarget(null) catch {
            try log.logError(.application, "Failed to set render target to window: {?s}", .{sdl3.errors.get()});
            continue;
        };

        renderer.setDrawColor(black) catch {
            try log.logWarn(.application, "Failed to set color: {?s}", .{sdl3.errors.get()});
        };
        renderer.clear() catch {
            try log.logError(.application, "Failed to clear screen: {?s}", .{sdl3.errors.get()});
            continue;
        };

        renderer.renderTexture(screen_buffer, null, null) catch {
            try log.logError(.application, "Failed to render screen buffer to window: {?s}", .{sdl3.errors.get()});
            continue;
        };

        renderer.present() catch {
            try log.logError(.application, "Failed to present renderer: {?s}", .{sdl3.errors.get()});
        };
    }
}
