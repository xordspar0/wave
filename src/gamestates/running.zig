const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const Keycode = @import("sdl3").keycode.Keycode;

const game = @import("../game.zig");

const gamestates = @import("gamestates.zig");
const State = gamestates.State;

const graphics = @import("../graphics/graphics.zig");
const Color = graphics.Color;
const drawable = graphics.drawable;

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

    pub fn draw(self: Running, a: Allocator) !ArrayList(drawable.Drawable) {
        var objects = ArrayList(drawable.Drawable).empty;

        for (self.game.dice) |die| {
            try objects.appendSlice(a, (try drawDie(a, die)).items);
        }
        try objects.appendSlice(a, (try drawCosts(a, &self.game.payments, 10, 30)).items);

        return objects;
    }

    fn drawDie(a: Allocator, die: game.Die) !ArrayList(drawable.Drawable) {
        var objects = ArrayList(drawable.Drawable).empty;

        if (die.value > 0) {
            try objects.append(a, drawable.Drawable{ .Texture = .{
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
            try objects.append(a, drawable.Drawable{ .Texture = .{
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

    fn drawCosts(a: Allocator, payments: []const game.Die, x: i16, y: i16) !ArrayList(drawable.Drawable) {
        const row_height = 32;
        const row_padding = 10;

        var objects = ArrayList(drawable.Drawable).empty;

        for (payments, 0..) |payment, i| {
            const row_y = y + @as(i16, @intCast(i)) * (row_height + row_padding);

            const menu_label = drawable.FilledRect{
                .x = x,
                .y = row_y,
                .w = 64,
                .h = row_height,
                .color = Color.rgb(180, 180, 180),
            };
            try objects.append(a, .{ .FilledRect = menu_label });

            const first_die_x = x + menu_label.w + row_padding;
            if (payment.value > 0) {
                try objects.appendSlice(a, (try drawDie(a, .{
                    .x = first_die_x,
                    .y = row_y,
                    .r = 0,
                    .value = payment.value,
                })).items);
            } else {
                try objects.append(a, drawable.Drawable{ .Texture = .{
                    .x = first_die_x,
                    .y = row_y,
                    .r = 0,
                    .origin = .top_left,
                    .sprite = .die_face_shadow,
                    .color = Color.rgb(255, 255, 255),
                } });
            }

            if (payment.value > 0) {
                try objects.appendSlice(a, (try shadow(a, try drawDie(a, payment))).items);
            } else {
                try objects.append(a, drawable.Drawable{
                    .Texture = .{
                        // TODO: 32 is a magic number that represents the width of a die sprite.
                        // Replace this with something smarter.
                        .x = first_die_x + 32 + row_padding,
                        .y = row_y,
                        .r = 0,
                        .origin = .top_left,
                        .sprite = .die_face_shadow,
                        .color = Color.rgb(255, 255, 255),
                    },
                });
            }
        }

        return objects;
    }

    fn shadow(a: Allocator, die: ArrayList(drawable.Drawable)) !ArrayList(drawable.Drawable) {
        // TODO: Do this without copying.
        var objects = ArrayList(drawable.Drawable).empty;

        for (die.items) |object| {
            try objects.append(a, switch (object) {
                .Texture => |texture| switch (texture.sprite) {
                    .die_face => build_shadow: {
                        var new = texture;
                        new.sprite = .die_face_shadow;
                        break :build_shadow drawable.Drawable{ .Texture = texture };
                    },
                    else => object,
                },
                else => object,
            });
        }

        return objects;
    }
};
