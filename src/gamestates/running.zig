const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const Keycode = @import("sdl3").keycode.Keycode;

const gamestates = @import("gamestates.zig");
const State = gamestates.State;

const game = @import("../game.zig");

const graphics = @import("../graphics/graphics.zig");
const Color = graphics.Color;
const Drawable = graphics.Drawable;

const vector = @import("../vector.zig");

pub const Running = struct {
    game: game.Game,

    pub fn update(self: Running) State {
        return .{ .Running = self };
    }

    pub fn keyDown(self: Running, key: Keycode) State {
        return switch (key) {
            .escape => .{ .MainMenu = .{} },
            // DEBUG: Press F5 to reroll the dice.
            .func5 => .{ .Running = .{ .game = self.game.rollDice() } },
            else => .{ .Running = self },
        };
    }

    pub fn draw(self: Running, a: Allocator) !ArrayList(Drawable) {
        var objects = ArrayList(Drawable).empty;

        for (self.game.dice) |die| {
            try objects.appendSlice(a, (try drawDie(a, die)).items);
        }

        return objects;
    }

    fn drawDie(a: Allocator, die: game.Die) !ArrayList(Drawable) {
        var objects = ArrayList(Drawable).empty;

        if (die.value > 0) {
            try objects.append(a, Drawable{ .Texture = .{
                .x = die.x,
                .y = die.y,
                .r = die.r,
                .origin = .center,
                .sprite = .die_face,
                .color = .rgb(255, 255, 255),
            } });
        }

        for (graphics.dice.dots_pos[die.value]) |dot| {
            const x, const y = vector.fromCoordinates(dot.x, dot.y)
                .rotate(@floatCast(die.r))
                .toCoordinates();
            try objects.append(a, Drawable{ .Texture = .{
                .x = die.x + @as(i16, @intFromFloat(x)),
                .y = die.y + @as(i16, @intFromFloat(y)),
                .r = 0,
                .origin = .center,
                .sprite = .die_dot,
                .color = .rgb(255, 255, 255),
            } });
        }

        return objects;
    }
};
