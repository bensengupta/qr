const std = @import("std");

const FORMAT_INFO_GENERATOR: u15 = 0x537;

pub fn encodeFormatInfo(formatInfo: u5) u15 {
    const fmt = @as(u15, formatInfo) << 10;
    var result = fmt;

    for (0..5) |i| {
        const shift: u4 = @intCast(i);
        const mask: u15 = @as(u15, 1) << (14 - shift);

        if (result & mask != 0) {
            result ^= FORMAT_INFO_GENERATOR << (4 - shift);
        }
    }

    return result | fmt;
}

test "works for example 1" {
    try std.testing.expect(encodeFormatInfo(0b00000) == 0b000000000000000);
    try std.testing.expect(encodeFormatInfo(0b00001) == 0b000010100110111);
}
