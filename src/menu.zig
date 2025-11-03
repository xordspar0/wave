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
        selected: u8 = 0,

        const button_width = 250;
        const button_height = 48;
        const button_padding = 5;
        const button_margin = 10;

        // TODO: Read input to change selection and return the selected button when the user presses enter.
        pub fn update(self: Self) ?Button {
            _ = self;

            return null;
        }

        pub fn draw(self: Self, a: Allocator) !ArrayList(Drawable) {
            var objects = ArrayList(Drawable).empty;

            for (self.buttons.values, 0..) |button, i| {
                // DEBUG
                std.debug.print("{s}\n", .{button});

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
