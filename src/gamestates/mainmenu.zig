const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const EnumArray = std.EnumArray;

const graphics = @import("../graphics/graphics.zig");
const Color = graphics.Color;
const Drawable = graphics.Drawable;

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
        }),
    },

    const Button = enum {
        new_game,
        high_scores,
    };

    pub fn update(self: MainMenu) ?State {
        if (self.menu.update()) |selected_button| {
            return switch (selected_button) {
                .new_game => State{ .Running = .{} },
                .high_scores => State{ .Scores = .{} },
            };
        }

        return null;
    }

    pub fn draw(self: MainMenu, a: Allocator) !ArrayList(Drawable) {
        var objects = ArrayList(Drawable).empty;

        // XXX: Is it really necessary to allocate space for the return value of menu.draw a second time?
        try objects.appendSlice(a, (try self.menu.draw(a)).items);

        // DEBUG
        try objects.append(a, Drawable{ .Texture = .{
            .x = 25,
            .y = 25,
            .r = 45,
            .origin = .center,
            .sprite = .die_face,
            .color = Color{ .r = 255, .g = 255, .b = 255 },
        } });

        return objects;
    }
};
