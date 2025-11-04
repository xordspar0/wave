const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const Keycode = @import("sdl3").keycode.Keycode;

const graphics = @import("../graphics/graphics.zig");
const Drawable = graphics.Drawable;

pub const MainMenu = @import("mainmenu.zig").MainMenu;

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

    pub fn keyDown(self: State, key: Keycode) State {
        return switch (self) {
            inline else => |impl| impl.keyDown(key),
        };
    }

    pub fn draw(self: State, a: Allocator) !ArrayList(Drawable) {
        return switch (self) {
            inline else => |impl| impl.draw(a),
        };
    }
};

pub const Scores = struct {
    fn update(self: Scores) State {
        return .{ .Scores = self };
    }

    fn keyDown(self: Scores, _: Keycode) State {
        return .{ .Scores = self };
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

    fn keyDown(self: Running, _: Keycode) State {
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

    fn keyDown(self: Quit, _: Keycode) State {
        return State{ .Quit = self };
    }

    fn draw(_: Quit, _: Allocator) !ArrayList(Drawable) {
        const objects = ArrayList(Drawable).empty;
        return objects;
    }
};
