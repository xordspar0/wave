const graphics = @import("graphics.zig");
const Color = graphics.Color;
const Origin = graphics.Origin;
const Sprite = @import("sprites.zig").Sprite;

pub const Drawable = union(enum) {
    FilledRect: FilledRect,
    Texture: Texture,
    Text: Text,
};

pub const FilledRect = struct {
    x: i16,
    y: i16,
    w: i16,
    h: i16,
    color: Color,
};

pub const Texture = struct {
    x: i16,
    y: i16,
    r: f64,
    origin: Origin,
    sprite: Sprite,
    color: Color,
};

pub const Text = struct {
    x: i16,
    y: i16,
    text: []u8,
};
