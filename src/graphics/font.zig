const std = @import("std");
const Allocator = std.mem.Allocator;
const EnumArray = std.enums.EnumArray;

const sdl3 = @import("sdl3");

pub const Font = struct {
    spritesheet: sdl3.render.Texture,
    char_width: u16,
    char_height: u16,

    pub fn getChar(self: Font, char: u8) sdl3.rect.FRect {
        return .{
            .x = @floatFromInt(char % self.char_width * self.char_width),
            .y = @floatFromInt(@divFloor(char, self.char_width) * self.char_height),
            .w = @floatFromInt(self.char_width),
            .h = @floatFromInt(self.char_height),
        };
    }
};

pub fn init(renderer: sdl3.render.Renderer) !Font {
    return .{
        .spritesheet = try sdl3.image.loadTexture(renderer, "font.png"),
        .char_width = 16,
        .char_height = 32,
    };
}
