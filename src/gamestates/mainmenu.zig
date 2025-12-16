const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const EnumArray = std.EnumArray;

const Keycode = @import("sdl3").keycode.Keycode;

const graphics = @import("../graphics/graphics.zig");
const Color = graphics.Color;
const drawable = graphics.drawable;

const game = @import("../game.zig");

const gamestates = @import("gamestates.zig");
const State = gamestates.State;

const Menu = @import("../menu.zig").Menu;

pub const MainMenu = struct {
    menu: Menu(Button) = .{
        .x = 200,
        .y = 100,
        .buttons = EnumArray(Button, []const u8).init(.{
            .new_game = "NEW GAME",
            .high_scores = "HIGH SCORES",
            .quit = "QUIT",
        }),
    },

    const Button = enum {
        new_game,
        high_scores,
        quit,
    };

    pub fn update(self: MainMenu) State {
        return .{ .MainMenu = self };
    }

    pub fn keyDown(self: MainMenu, key: Keycode) State {
        return switch (key) {
            .up => .{ .MainMenu = .{ .menu = self.menu.up() } },
            .down => .{ .MainMenu = .{ .menu = self.menu.down() } },
            .return_key => switch (self.menu.select()) {
                .new_game => .{ .Running = .{ .game = game.Game.init().rollDice() } },
                .high_scores => .{ .Scores = .{} },
                .quit => .{ .Quit = .{} },
            },
            else => .{ .MainMenu = self },
        };
    }

    pub fn draw(self: MainMenu, a: Allocator) !ArrayList(drawable.Drawable) {
        return try self.menu.draw(a);
    }
};
