const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const graphics = @import("graphics/graphics.zig");
const Drawable = graphics.Drawable;
const Color = graphics.Color;

pub const Game = struct {
    state: State,
    dice: [4]Die,
    payments: [6]Die,
};

pub const State = union(enum) {
    MainMenu: MainMenu,
    Scores: Scores,
    Running: Running,
    Quit: Quit,

    pub fn update(self: State) State {
        return switch (self) {
            inline else => |impl| impl.update(),
        };
    }

    pub fn draw(self: State, a: Allocator) !ArrayList(Drawable) {
        return switch (self) {
            inline else => |impl| impl.draw(a),
        };
    }
};

const MainMenu = struct {
    fn update(self: MainMenu) State {
        return State{ .MainMenu = self };
    }

    fn draw(_: MainMenu, a: Allocator) !ArrayList(Drawable) {
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

const Scores = struct {
    fn update(self: Scores) State {
        return State{ .Scores = self };
    }

    fn draw(_: Scores, _: Allocator) !ArrayList(Drawable) {
        const objects = ArrayList(Drawable).empty;
        return objects;
    }
};

const Running = struct {
    fn update(self: Running) State {
        return State{ .Running = self };
    }

    fn draw(_: Running, _: Allocator) !ArrayList(Drawable) {
        const objects = ArrayList(Drawable).empty;
        return objects;
    }
};

const Quit = struct {
    fn update(self: Quit) State {
        return State{ .Quit = self };
    }

    fn draw(_: Quit, _: Allocator) !ArrayList(Drawable) {
        const objects = ArrayList(Drawable).empty;
        return objects;
    }
};

pub const Die = struct {
    x: i16,
    y: i16,
    r: f64,
    value: u8,
};
