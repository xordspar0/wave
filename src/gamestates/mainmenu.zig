const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const graphics = @import("../graphics/graphics.zig");
const Color = graphics.Color;
const Drawable = graphics.Drawable;

const State = @import("gamestates.zig").State;

const button_width = 250;
const button_height = 48;
const button_padding = 5;
const button_margin = 10;

pub const MainMenu = struct {
    selected: u8 = 0,
    accepted: bool = false,
    buttons: []Button,

    pub fn init(a: Allocator, labels: []const []const u8) !MainMenu {
        var buttons = ArrayList(Button).empty;

        for (labels, 0..) |label, i| {
            try buttons.append(a, .{
                .x = 20,
                .y = @intCast((i + 1) * (button_height + button_margin)),
                .w = button_width,
                .h = button_height,
                .text = label,
            });
        }

        return .{ .buttons = buttons.items };
    }

    pub fn update(self: MainMenu) State {
        return State{ .MainMenu = self };
    }

    pub fn draw(self: MainMenu, a: Allocator) !ArrayList(Drawable) {
        var objects = ArrayList(Drawable).empty;

        for (self.buttons, 0..) |button, i| {
            try objects.append(a, Drawable{ .FilledRect = .{
                .x = button.x + button_padding,
                .y = button.y + button_padding,
                .w = button.w - button_padding * 2,
                .h = button.h - button_padding * 2,
                .color = if (i == self.selected) Color.rgb(128, 128, 255) else Color.rgb(128, 128, 128),
            } });
        }

        // debug:
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

const Button = struct {
    x: i16,
    y: i16,
    w: i16,
    h: i16,

    text: []const u8,
};
