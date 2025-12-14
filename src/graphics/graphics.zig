pub const Drawable = @import("drawable.zig").Drawable;
pub const dice = @import("dice.zig");
pub const font = @import("font.zig");
pub const sprites = @import("sprites.zig");

pub const Color = struct {
    r: u8,
    g: u8,
    b: u8,

    pub fn rgb(r: u8, g: u8, b: u8) Color {
        return .{ .r = r, .g = g, .b = b };
    }
};

pub const Origin = enum { top_left, center };
