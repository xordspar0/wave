const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const Keycode = @import("sdl3").keycode.Keycode;

const graphics = @import("../graphics/graphics.zig");
const drawable = graphics.drawable;

pub const MainMenu = @import("mainmenu.zig").MainMenu;
pub const Running = @import("running.zig").Running;

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

    // TODO: Think about io arg. Is it desirable?
    // Should all functions in the interface take an io arg?
    // Should it be the third arg, or should it be in a different position?
    pub fn keyDown(self: State, key: Keycode, io: std.Io) State {
        return switch (self) {
            inline else => |impl| impl.keyDown(key, io),
        };
    }

    pub fn mouseButtonDown(self: State, x: i16, y: i16) State {
        return switch (self) {
            inline else => |impl| impl.mouseButtonDown(x, y),
        };
    }

    pub fn draw(self: State, a: Allocator) !ArrayList(drawable.Drawable) {
        return switch (self) {
            inline else => |impl| impl.draw(a),
        };
    }
};

pub const Scores = struct {
    fn update(self: Scores) State {
        return .{ .Scores = self };
    }

    fn keyDown(self: Scores, _: Keycode, _: std.Io) State {
        return .{ .Scores = self };
    }

    fn mouseButtonDown(self: Scores, _: i16, _: i16) State {
        return .{ .Scores = self };
    }

    fn draw(_: Scores, _: Allocator) !ArrayList(drawable.Drawable) {
        return ArrayList(drawable.Drawable).empty;
    }
};

const Quit = struct {
    fn update(self: Quit) State {
        return State{ .Quit = self };
    }

    fn keyDown(self: Quit, _: Keycode, _: std.Io) State {
        return State{ .Quit = self };
    }

    fn mouseButtonDown(self: Quit, _: i16, _: i16) State {
        return .{ .Quit = self };
    }

    fn draw(_: Quit, _: Allocator) !ArrayList(drawable.Drawable) {
        return ArrayList(drawable.Drawable).empty;
    }
};
