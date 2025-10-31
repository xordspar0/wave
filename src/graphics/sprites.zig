const std = @import("std");
const Allocator = std.mem.Allocator;
const EnumArray = std.enums.EnumArray;

const sdl3 = @import("sdl3");

pub const Sprite = enum {
    die_face,
    die_face_shadow,
    die_dot,
};

pub const SpriteData = struct {
    spritesheet_name: []const u8,
    spritesheet: sdl3.render.Texture,
    rect: sdl3.rect.FRect,
};

pub fn init(renderer: sdl3.render.Renderer) !EnumArray(Sprite, SpriteData) {
    const dice_texture = try sdl3.image.loadTexture(renderer, "dice.png");

    return EnumArray(Sprite, SpriteData).init(
        .{
            .die_face = .{
                .spritesheet_name = "dice.png",
                .spritesheet = dice_texture,
                .rect = .{ .x = 0, .y = 0, .w = 32, .h = 32 },
            },
            .die_face_shadow = .{
                .spritesheet_name = "dice.png",
                .spritesheet = dice_texture,
                .rect = .{ .x = 32, .y = 0, .w = 32, .h = 32 },
            },
            .die_dot = .{
                .spritesheet_name = "dice.png",
                .spritesheet = dice_texture,
                .rect = .{ .x = 64, .y = 0, .w = 6, .h = 6 },
            },
        },
    );
}
