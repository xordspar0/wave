const math = @import("std").math;

// A Euclidean vector with magnitude and angle.
// The angle is in degrees.
pub fn Vector(T: type) type {
    return struct {
        const Self = @This();

        magnitude: T,
        angle: T,

        pub fn rotate(self: Self, angleDifference: T) Self {
            return .{
                .magnitude = self.magnitude,
                .angle = self.angle + angleDifference,
            };
        }

        pub fn toCoordinates(self: Self) struct { T, T } {
            return .{
                self.magnitude * @cos(math.degreesToRadians(self.angle)),
                self.magnitude * @sin(math.degreesToRadians(self.angle)),
            };
        }
    };
}

pub fn fromCoordinates(x: anytype, y: anytype) Vector(@TypeOf(x, y)) {
    return .{
        .magnitude = @sqrt(x * x + y * y),
        .angle = math.radiansToDegrees(math.atan2(y, x)),
    };
}
