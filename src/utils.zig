const std = @import("std");

const assert = std.debug.assert;

pub fn splitIntoBits(comptime T: type, value: T, slice: []u1) void {
    assert(slice.len == @bitSizeOf(T));

    const n = @bitSizeOf(T);
    var val = value;
    for (0..n) |i| {
        slice[n - i - 1] = @intCast(val & 1);
        val >>= 1;
    }
}
