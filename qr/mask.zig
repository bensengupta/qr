const std = @import("std");
const BitMatrix = @import("bit-matrix.zig").BitMatrix;

const PENALTY_WEIGHT_N1 = 3;
const PENALTY_WEIGHT_N2 = 3;
const PENALTY_WEIGHT_N3 = 40;
const PENALTY_WEIGHT_N4 = 10;

pub const MASK_PATTERN_0: u3 = 0b000;
pub const MASK_PATTERN_1: u3 = 0b001;
pub const MASK_PATTERN_2: u3 = 0b010;
pub const MASK_PATTERN_3: u3 = 0b011;
pub const MASK_PATTERN_4: u3 = 0b100;
pub const MASK_PATTERN_5: u3 = 0b101;
pub const MASK_PATTERN_6: u3 = 0b110;
pub const MASK_PATTERN_7: u3 = 0b111;

pub fn applyPattern(maskPattern: u3, pixels: BitMatrix, reserved: BitMatrix) void {
    for (0..pixels.size) |i| {
        for (0..pixels.size) |j| {
            if (reserved.get(i, j) == 0) {
                const patternBool: bool = switch (maskPattern) {
                    MASK_PATTERN_0 => (i + j) % 2 == 0,
                    MASK_PATTERN_1 => i % 2 == 0,
                    MASK_PATTERN_2 => j % 3 == 0,
                    MASK_PATTERN_3 => (i + j) % 3 == 0,
                    MASK_PATTERN_4 => ((i / 2) + (j / 3)) % 2 == 0,
                    MASK_PATTERN_5 => (i * j) % 2 + (i * j) % 3 == 0,
                    MASK_PATTERN_6 => ((i * j) % 2 + (i * j) % 3) % 2 == 0,
                    MASK_PATTERN_7 => ((i * j) % 3 + (i + j) % 2) % 2 == 0,
                };

                const patternBit: u1 = @intFromBool(patternBool);
                const newBit = pixels.get(i, j) ^ patternBit;

                pixels.set(i, j, newBit);
            }
        }
    }
}

fn computePenaltyN1(pixels: BitMatrix) usize {
    var penalty: usize = 0;

    for (0..pixels.size) |i| {
        var rowNumSame: usize = 1;
        var colNumSame: usize = 1;

        for (1..pixels.size) |j| {
            // Row check
            if (pixels.get(i, j - 1) == pixels.get(i, j)) {
                rowNumSame += 1;
            } else {
                if (rowNumSame >= 5) {
                    penalty += PENALTY_WEIGHT_N1 + (rowNumSame - 5);
                }
                rowNumSame = 1;
            }

            // Col check
            if (pixels.get(j - 1, i) == pixels.get(j, i)) {
                colNumSame += 1;
            } else {
                if (colNumSame >= 5) {
                    penalty += PENALTY_WEIGHT_N1 + (colNumSame - 5);
                }
                colNumSame = 1;
            }
        }

        if (rowNumSame >= 5) {
            penalty += PENALTY_WEIGHT_N1 + (rowNumSame - 5);
        }

        if (colNumSame >= 5) {
            penalty += PENALTY_WEIGHT_N1 + (colNumSame - 5);
        }
    }

    return penalty;
}

fn computePenaltyN2(pixels: BitMatrix) usize {
    var penalty: usize = 0;

    for (0..(pixels.size - 1)) |r| {
        for (0..(pixels.size - 1)) |c| {
            if (pixels.get(r, c) == pixels.get(r, c + 1) and pixels.get(r, c) == pixels.get(r + 1, c) and pixels.get(r, c) == pixels.get(r + 1, c + 1)) {
                penalty += PENALTY_WEIGHT_N2;
            }
        }
    }

    return penalty;
}

fn computePenaltyN3(pixels: BitMatrix) usize {
    var penalty: usize = 0;

    for (0..pixels.size) |i| {
        var row: u16 = 0;
        var col: u16 = 0;
        for (0..pixels.size) |j| {
            row = (row << 1) & 0x7ff | pixels.get(i, j);
            if (j >= 10 and (row == 0x5d0 or row == 0x05d)) {
                penalty += PENALTY_WEIGHT_N3;
            }

            col = (col << 1) & 0x7ff | pixels.get(j, i);
            if (j >= 10 and (col == 0x5d0 or col == 0x05d)) {
                penalty += PENALTY_WEIGHT_N3;
            }
        }
    }

    return penalty;
}

fn computePenaltyN4(pixels: BitMatrix) usize {
    var darkModulesInt: usize = 0;
    for (0..pixels.size) |r| {
        for (0..pixels.size) |c| {
            darkModulesInt += @intCast(pixels.get(r, c));
        }
    }

    const totalModules: f32 = @floatFromInt(pixels.size * pixels.size);
    const darkModules: f32 = @floatFromInt(darkModulesInt);

    const proportion = darkModules / totalModules;

    const increment = @abs(proportion - 0.50) * 100.0;
    const k: usize = @intFromFloat(@floor(increment / 5.0));

    return PENALTY_WEIGHT_N4 * k;
}

pub fn applyBestPattern(pixels: BitMatrix, reserved: BitMatrix) u3 {
    const patterns = [_]u3{ MASK_PATTERN_0, MASK_PATTERN_1, MASK_PATTERN_2, MASK_PATTERN_3, MASK_PATTERN_4, MASK_PATTERN_5, MASK_PATTERN_6, MASK_PATTERN_7 };

    var minPenalty: usize = std.math.maxInt(usize);
    var bestPattern: u3 = 0;
    for (patterns) |pattern| {
        applyPattern(pattern, pixels, reserved);

        std.log.info("mask_pattern: {}", .{pattern});
        @import("ansi-renderer.zig").render(pixels) catch unreachable;

        const n1 = computePenaltyN1(pixels);
        const n2 = computePenaltyN2(pixels);
        const n3 = computePenaltyN3(pixels);
        const n4 = computePenaltyN4(pixels);
        const penalty = n1 + n2 + n3 + n4;
        std.log.debug("mask_pattern: pattern {} penalty {} (n1={} n2={} n3={} n4={})", .{ pattern, penalty, n1, n2, n3, n4 });

        if (penalty < minPenalty) {
            minPenalty = penalty;
            bestPattern = pattern;
        }

        // Reverse pattern (XOR)
        applyPattern(pattern, pixels, reserved);
    }
    std.log.debug("mask_pattern: best pattern {} penalty is {}", .{ bestPattern, minPenalty });

    applyPattern(bestPattern, pixels, reserved);

    return bestPattern;
}
