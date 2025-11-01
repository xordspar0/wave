const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const graphics = @import("../graphics/graphics.zig");
const Color = graphics.Color;
const Drawable = graphics.Drawable;

const State = @import("gamestates.zig").State;

pub const MainMenu = struct {
    pub fn update(self: MainMenu) State {
        return State{ .MainMenu = self };
    }

    pub fn draw(_: MainMenu, a: Allocator) !ArrayList(Drawable) {
        var objects = ArrayList(Drawable).empty;

        try objects.append(a, Drawable{ .FilledRect = .{
            .x = 25,
            .y = 25,
            .w = 100,
            .h = 100,
            .color = Color{ .r = 128, .g = 128, .b = 255 },
        } });

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
