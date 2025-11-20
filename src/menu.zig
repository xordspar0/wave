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

        pub fn up(old: Self) Self {
            var new = old;

            new.selected = std.math.clamp(old.selected - 1, 0, old.buttons.values.len - 1);

            return new;
        }

        pub fn down(old: Self) Self {
            var new = old;

            new.selected = std.math.clamp(old.selected + 1, 0, old.buttons.values.len - 1);

            return new;
        }

        pub fn select(self: Self) Button {
            return @enumFromInt(self.selected);
        }

        pub fn draw(self: Self, a: Allocator) !ArrayList(Drawable) {
            var objects = ArrayList(Drawable).empty;

            for (self.buttons.values, 0..) |label, i| {
                const button_x = self.x;
                const button_y = self.y + @as(i16, @intCast(i * (button_height + button_margin)));

                try objects.append(a, Drawable{ .FilledRect = .{
                    .x = button_x,
                    .y = button_y,
                    .w = button_width,
                    .h = button_height,
                    .color = if (i == self.selected) Color.rgb(128, 128, 255) else Color.rgb(128, 128, 128),
                } });

                try objects.append(a, Drawable{ .Text = .{
                    .x = button_x + button_padding,
                    .y = button_y + button_padding,
                    .text = try a.dupe(u8, label),
                } });
            }

            return objects;
        }
    };
}
