pub const Drawable = @import("drawable.zig").Drawable;
pub const sprites = @import("sprites.zig");

pub const Color = struct {
    r: u8,
    g: u8,
    b: u8,
};

pub const Origin = enum { top_left, center };
