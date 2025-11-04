const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const EnumArray = std.EnumArray;

const graphics = @import("graphics/graphics.zig");
const Color = graphics.Color;
const Drawable = graphics.Drawable;

pub fn Menu(comptime Button: type) type {
    return struct {
        const Self = @This();

        x: i16,
        y: i16,
        buttons: EnumArray(Button, []const u8),
        selected: isize = 0,

        const button_width = 250;
        const button_height = 48;
        const button_padding = 5;
        const button_margin = 10;

        pub fn up(self: Self) Self {
            return .{
                .x = self.x,
                .y = self.y,
                .buttons = self.buttons,
                .selected = std.math.clamp(self.selected - 1, 0, self.buttons.values.len - 1),
            };
        }

        pub fn down(self: Self) Self {
            return .{
                .x = self.x,
                .y = self.y,
                .buttons = self.buttons,
                .selected = std.math.clamp(self.selected + 1, 0, self.buttons.values.len - 1),
            };
        }

        pub fn select(self: Self) Button {
            return @enumFromInt(self.selected);
        }

        pub fn draw(self: Self, a: Allocator) !ArrayList(Drawable) {
            var objects = ArrayList(Drawable).empty;

            for (0..self.buttons.values.len) |i| {
                try objects.append(a, Drawable{ .FilledRect = .{
                    .x = self.x,
                    .y = self.y + @as(i16, @intCast(i * (button_height + button_margin))),
                    .w = button_width,
                    .h = button_height,
                    .color = if (i == self.selected) Color.rgb(128, 128, 255) else Color.rgb(128, 128, 128),
                } });
            }

            return objects;
        }
    };
}
