const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const graphics = @import("graphics/graphics.zig");
const Drawable = graphics.Drawable;
const Color = graphics.Color;

pub const Game = struct {
    dice: [4]Die,
    payments: [6]?Die,

    pub fn init() Game {
        return .{
            .dice = .{Die{ .x = 0, .y = 0, .r = 0, .value = 0 }} ** 4,
            .payments = .{null} ** 6,
        };
    }

    pub fn rollDice(self: Game, io: std.Io) Game {
        var g = self;

        const rand_impl = std.Random.IoSource{ .io = io };
        const rand = rand_impl.interface();

        for (0..g.dice.len) |i| {
            g.dice[i] = .{
                .x = @as(i16, @intCast(i)) * 40 + 200,
                .y = 60,
                .r = rand.float(f64) * 360,
                .value = rand.intRangeAtMost(u8, 1, 6),
            };
        }

        return g;
    }
};

pub const Die = struct {
    x: i16,
    y: i16,
    r: f64,
    value: u8,
};
