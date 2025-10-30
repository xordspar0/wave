pub const Drawable = @import("drawable.zig").Drawable;

pub const Color = struct {
    r: u8,
    g: u8,
    b: u8,
};

pub const Origin = enum { TopLeft, Center };
