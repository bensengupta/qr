const std = @import("std");
const BitMatrix = @import("bit-matrix.zig").BitMatrix;

pub const Pattern0: u3 = 0b000;
pub const Pattern1: u3 = 0b001;
pub const Pattern2: u3 = 0b010;
pub const Pattern3: u3 = 0b011;
pub const Pattern4: u3 = 0b100;
pub const Pattern5: u3 = 0b101;
pub const Pattern6: u3 = 0b110;
pub const Pattern7: u3 = 0b111;

pub fn applyPattern(maskPattern: u3, pixels: BitMatrix, reserved: BitMatrix) void {
    for (0..pixels.size) |i| {
        for (0..pixels.size) |j| {
            if (reserved.get(i, j) == 0) {
                const patternBool: bool = switch (maskPattern) {
                    .Pattern0 => (i + j) % 2 == 0,
                    .Pattern1 => i % 2 == 0,
                    .Pattern2 => j % 3 == 0,
                    .Pattern3 => (i + j) % 3 == 0,
                    .Pattern4 => ((i / 2) + (j / 3)) % 2 == 0,
                    .Pattern5 => (i * j) % 2 + (i * j) % 3 == 0,
                    .Pattern6 => ((i * j) % 2 + (i * j) % 3) % 2 == 0,
                    .Pattern7 => ((i + j) % 2 + (i * j) % 3) % 2 == 0,
                };

                const patternBit: u1 = @intFromBool(patternBool);
                const newBit = pixels.get(i, j) ^ patternBit;

                pixels.set(i, j, newBit);
            }
        }
    }
}

pub fn applyBestPattern(pixels: BitMatrix, reserved: BitMatrix) u3 {
    _ = reserved;
    _ = pixels;
}
