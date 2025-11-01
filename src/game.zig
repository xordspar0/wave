const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const graphics = @import("graphics/graphics.zig");
const Drawable = graphics.Drawable;
const Color = graphics.Color;

const gamestates = @import("gamestates/gamestates.zig");

pub const Game = struct {
    state: gamestates.State,
    dice: [4]Die,
    payments: [6]Die,
};

pub const Die = struct {
    x: i16,
    y: i16,
    r: f64,
    value: u8,
};
