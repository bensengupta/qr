const std = @import("std");
const galois = @import("galois-field.zig");

const Allocator = std.mem.Allocator;
const GaloisField = galois.GaloisField;
const Polynomial = galois.Polynomial;

pub const ErrorCorrectionLevel = enum(u2) {
    L = 0b01,
    M = 0b00,
    Q = 0b11,
    H = 0b10,
};

pub fn getErrorCorrectionCodewords(version: usize, ecLevel: ErrorCorrectionLevel) usize {
    return switch (version) {
        1 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 7,
            ErrorCorrectionLevel.M => 10,
            ErrorCorrectionLevel.Q => 13,
            ErrorCorrectionLevel.H => 17,
        },
        2 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 10,
            ErrorCorrectionLevel.M => 16,
            ErrorCorrectionLevel.Q => 22,
            ErrorCorrectionLevel.H => 28,
        },
        3 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 15,
            ErrorCorrectionLevel.M => 26,
            ErrorCorrectionLevel.Q => 36,
            ErrorCorrectionLevel.H => 44,
        },
        4 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 20,
            ErrorCorrectionLevel.M => 36,
            ErrorCorrectionLevel.Q => 52,
            ErrorCorrectionLevel.H => 64,
        },
        5 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 26,
            ErrorCorrectionLevel.M => 48,
            ErrorCorrectionLevel.Q => 72,
            ErrorCorrectionLevel.H => 88,
        },
        6 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 36,
            ErrorCorrectionLevel.M => 64,
            ErrorCorrectionLevel.Q => 96,
            ErrorCorrectionLevel.H => 112,
        },
        7 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 40,
            ErrorCorrectionLevel.M => 72,
            ErrorCorrectionLevel.Q => 108,
            ErrorCorrectionLevel.H => 130,
        },
        8 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 48,
            ErrorCorrectionLevel.M => 88,
            ErrorCorrectionLevel.Q => 132,
            ErrorCorrectionLevel.H => 156,
        },
        9 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 60,
            ErrorCorrectionLevel.M => 110,
            ErrorCorrectionLevel.Q => 160,
            ErrorCorrectionLevel.H => 192,
        },
        10 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 72,
            ErrorCorrectionLevel.M => 130,
            ErrorCorrectionLevel.Q => 192,
            ErrorCorrectionLevel.H => 224,
        },
        11 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 80,
            ErrorCorrectionLevel.M => 150,
            ErrorCorrectionLevel.Q => 224,
            ErrorCorrectionLevel.H => 264,
        },
        12 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 96,
            ErrorCorrectionLevel.M => 176,
            ErrorCorrectionLevel.Q => 260,
            ErrorCorrectionLevel.H => 308,
        },
        13 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 104,
            ErrorCorrectionLevel.M => 198,
            ErrorCorrectionLevel.Q => 288,
            ErrorCorrectionLevel.H => 352,
        },
        14 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 120,
            ErrorCorrectionLevel.M => 216,
            ErrorCorrectionLevel.Q => 320,
            ErrorCorrectionLevel.H => 384,
        },
        15 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 132,
            ErrorCorrectionLevel.M => 240,
            ErrorCorrectionLevel.Q => 360,
            ErrorCorrectionLevel.H => 432,
        },
        16 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 144,
            ErrorCorrectionLevel.M => 280,
            ErrorCorrectionLevel.Q => 408,
            ErrorCorrectionLevel.H => 480,
        },
        17 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 168,
            ErrorCorrectionLevel.M => 308,
            ErrorCorrectionLevel.Q => 448,
            ErrorCorrectionLevel.H => 532,
        },
        18 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 180,
            ErrorCorrectionLevel.M => 338,
            ErrorCorrectionLevel.Q => 504,
            ErrorCorrectionLevel.H => 588,
        },
        19 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 196,
            ErrorCorrectionLevel.M => 364,
            ErrorCorrectionLevel.Q => 546,
            ErrorCorrectionLevel.H => 650,
        },
        20 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 224,
            ErrorCorrectionLevel.M => 416,
            ErrorCorrectionLevel.Q => 600,
            ErrorCorrectionLevel.H => 700,
        },
        21 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 224,
            ErrorCorrectionLevel.M => 442,
            ErrorCorrectionLevel.Q => 644,
            ErrorCorrectionLevel.H => 750,
        },
        22 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 252,
            ErrorCorrectionLevel.M => 476,
            ErrorCorrectionLevel.Q => 690,
            ErrorCorrectionLevel.H => 816,
        },
        23 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 270,
            ErrorCorrectionLevel.M => 504,
            ErrorCorrectionLevel.Q => 750,
            ErrorCorrectionLevel.H => 900,
        },
        24 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 300,
            ErrorCorrectionLevel.M => 560,
            ErrorCorrectionLevel.Q => 810,
            ErrorCorrectionLevel.H => 960,
        },
        25 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 312,
            ErrorCorrectionLevel.M => 588,
            ErrorCorrectionLevel.Q => 870,
            ErrorCorrectionLevel.H => 1050,
        },
        26 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 336,
            ErrorCorrectionLevel.M => 644,
            ErrorCorrectionLevel.Q => 952,
            ErrorCorrectionLevel.H => 1110,
        },
        27 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 360,
            ErrorCorrectionLevel.M => 700,
            ErrorCorrectionLevel.Q => 1020,
            ErrorCorrectionLevel.H => 1200,
        },
        28 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 390,
            ErrorCorrectionLevel.M => 728,
            ErrorCorrectionLevel.Q => 1050,
            ErrorCorrectionLevel.H => 1260,
        },
        29 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 420,
            ErrorCorrectionLevel.M => 784,
            ErrorCorrectionLevel.Q => 1140,
            ErrorCorrectionLevel.H => 1350,
        },
        30 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 450,
            ErrorCorrectionLevel.M => 812,
            ErrorCorrectionLevel.Q => 1200,
            ErrorCorrectionLevel.H => 1440,
        },
        31 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 480,
            ErrorCorrectionLevel.M => 868,
            ErrorCorrectionLevel.Q => 1290,
            ErrorCorrectionLevel.H => 1530,
        },
        32 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 510,
            ErrorCorrectionLevel.M => 924,
            ErrorCorrectionLevel.Q => 1350,
            ErrorCorrectionLevel.H => 1620,
        },
        33 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 540,
            ErrorCorrectionLevel.M => 980,
            ErrorCorrectionLevel.Q => 1440,
            ErrorCorrectionLevel.H => 1710,
        },
        34 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 570,
            ErrorCorrectionLevel.M => 1036,
            ErrorCorrectionLevel.Q => 1530,
            ErrorCorrectionLevel.H => 1800,
        },
        35 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 570,
            ErrorCorrectionLevel.M => 1064,
            ErrorCorrectionLevel.Q => 1590,
            ErrorCorrectionLevel.H => 1890,
        },
        36 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 600,
            ErrorCorrectionLevel.M => 1120,
            ErrorCorrectionLevel.Q => 1680,
            ErrorCorrectionLevel.H => 1980,
        },
        37 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 630,
            ErrorCorrectionLevel.M => 1204,
            ErrorCorrectionLevel.Q => 1770,
            ErrorCorrectionLevel.H => 2100,
        },
        38 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 660,
            ErrorCorrectionLevel.M => 1260,
            ErrorCorrectionLevel.Q => 1860,
            ErrorCorrectionLevel.H => 2220,
        },
        39 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 720,
            ErrorCorrectionLevel.M => 1316,
            ErrorCorrectionLevel.Q => 1950,
            ErrorCorrectionLevel.H => 2310,
        },
        40 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 750,
            ErrorCorrectionLevel.M => 1372,
            ErrorCorrectionLevel.Q => 2040,
            ErrorCorrectionLevel.H => 2430,
        },
        else => unreachable,
    };
}

pub fn getErrorCorrectionBlocks(version: usize, ecLevel: ErrorCorrectionLevel) usize {
    return switch (version) {
        1 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 1,
            ErrorCorrectionLevel.M => 1,
            ErrorCorrectionLevel.Q => 1,
            ErrorCorrectionLevel.H => 1,
        },
        2 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 1,
            ErrorCorrectionLevel.M => 1,
            ErrorCorrectionLevel.Q => 1,
            ErrorCorrectionLevel.H => 1,
        },
        3 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 1,
            ErrorCorrectionLevel.M => 1,
            ErrorCorrectionLevel.Q => 2,
            ErrorCorrectionLevel.H => 2,
        },
        4 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 1,
            ErrorCorrectionLevel.M => 2,
            ErrorCorrectionLevel.Q => 2,
            ErrorCorrectionLevel.H => 4,
        },
        5 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 1,
            ErrorCorrectionLevel.M => 2,
            ErrorCorrectionLevel.Q => 4,
            ErrorCorrectionLevel.H => 4,
        },
        6 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 2,
            ErrorCorrectionLevel.M => 4,
            ErrorCorrectionLevel.Q => 4,
            ErrorCorrectionLevel.H => 4,
        },
        7 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 2,
            ErrorCorrectionLevel.M => 4,
            ErrorCorrectionLevel.Q => 6,
            ErrorCorrectionLevel.H => 5,
        },
        8 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 2,
            ErrorCorrectionLevel.M => 4,
            ErrorCorrectionLevel.Q => 6,
            ErrorCorrectionLevel.H => 6,
        },
        9 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 2,
            ErrorCorrectionLevel.M => 5,
            ErrorCorrectionLevel.Q => 8,
            ErrorCorrectionLevel.H => 8,
        },
        10 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 4,
            ErrorCorrectionLevel.M => 5,
            ErrorCorrectionLevel.Q => 8,
            ErrorCorrectionLevel.H => 8,
        },
        11 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 4,
            ErrorCorrectionLevel.M => 5,
            ErrorCorrectionLevel.Q => 8,
            ErrorCorrectionLevel.H => 11,
        },
        12 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 4,
            ErrorCorrectionLevel.M => 8,
            ErrorCorrectionLevel.Q => 10,
            ErrorCorrectionLevel.H => 11,
        },
        13 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 4,
            ErrorCorrectionLevel.M => 9,
            ErrorCorrectionLevel.Q => 12,
            ErrorCorrectionLevel.H => 16,
        },
        14 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 4,
            ErrorCorrectionLevel.M => 9,
            ErrorCorrectionLevel.Q => 16,
            ErrorCorrectionLevel.H => 16,
        },
        15 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 6,
            ErrorCorrectionLevel.M => 10,
            ErrorCorrectionLevel.Q => 12,
            ErrorCorrectionLevel.H => 18,
        },
        16 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 6,
            ErrorCorrectionLevel.M => 10,
            ErrorCorrectionLevel.Q => 17,
            ErrorCorrectionLevel.H => 16,
        },
        17 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 6,
            ErrorCorrectionLevel.M => 11,
            ErrorCorrectionLevel.Q => 16,
            ErrorCorrectionLevel.H => 19,
        },
        18 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 6,
            ErrorCorrectionLevel.M => 13,
            ErrorCorrectionLevel.Q => 18,
            ErrorCorrectionLevel.H => 21,
        },
        19 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 7,
            ErrorCorrectionLevel.M => 14,
            ErrorCorrectionLevel.Q => 21,
            ErrorCorrectionLevel.H => 25,
        },
        20 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 8,
            ErrorCorrectionLevel.M => 16,
            ErrorCorrectionLevel.Q => 20,
            ErrorCorrectionLevel.H => 25,
        },
        21 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 8,
            ErrorCorrectionLevel.M => 17,
            ErrorCorrectionLevel.Q => 23,
            ErrorCorrectionLevel.H => 25,
        },
        22 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 9,
            ErrorCorrectionLevel.M => 17,
            ErrorCorrectionLevel.Q => 23,
            ErrorCorrectionLevel.H => 34,
        },
        23 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 9,
            ErrorCorrectionLevel.M => 18,
            ErrorCorrectionLevel.Q => 25,
            ErrorCorrectionLevel.H => 30,
        },
        24 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 10,
            ErrorCorrectionLevel.M => 20,
            ErrorCorrectionLevel.Q => 27,
            ErrorCorrectionLevel.H => 32,
        },
        25 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 12,
            ErrorCorrectionLevel.M => 21,
            ErrorCorrectionLevel.Q => 29,
            ErrorCorrectionLevel.H => 35,
        },
        26 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 12,
            ErrorCorrectionLevel.M => 23,
            ErrorCorrectionLevel.Q => 34,
            ErrorCorrectionLevel.H => 37,
        },
        27 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 12,
            ErrorCorrectionLevel.M => 25,
            ErrorCorrectionLevel.Q => 34,
            ErrorCorrectionLevel.H => 40,
        },
        28 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 13,
            ErrorCorrectionLevel.M => 26,
            ErrorCorrectionLevel.Q => 35,
            ErrorCorrectionLevel.H => 42,
        },
        29 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 14,
            ErrorCorrectionLevel.M => 28,
            ErrorCorrectionLevel.Q => 38,
            ErrorCorrectionLevel.H => 45,
        },
        30 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 15,
            ErrorCorrectionLevel.M => 29,
            ErrorCorrectionLevel.Q => 40,
            ErrorCorrectionLevel.H => 48,
        },
        31 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 16,
            ErrorCorrectionLevel.M => 31,
            ErrorCorrectionLevel.Q => 43,
            ErrorCorrectionLevel.H => 51,
        },
        32 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 17,
            ErrorCorrectionLevel.M => 33,
            ErrorCorrectionLevel.Q => 45,
            ErrorCorrectionLevel.H => 54,
        },
        33 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 18,
            ErrorCorrectionLevel.M => 35,
            ErrorCorrectionLevel.Q => 48,
            ErrorCorrectionLevel.H => 57,
        },
        34 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 19,
            ErrorCorrectionLevel.M => 37,
            ErrorCorrectionLevel.Q => 51,
            ErrorCorrectionLevel.H => 60,
        },
        35 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 19,
            ErrorCorrectionLevel.M => 38,
            ErrorCorrectionLevel.Q => 53,
            ErrorCorrectionLevel.H => 63,
        },
        36 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 20,
            ErrorCorrectionLevel.M => 40,
            ErrorCorrectionLevel.Q => 56,
            ErrorCorrectionLevel.H => 66,
        },
        37 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 21,
            ErrorCorrectionLevel.M => 43,
            ErrorCorrectionLevel.Q => 59,
            ErrorCorrectionLevel.H => 70,
        },
        38 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 22,
            ErrorCorrectionLevel.M => 45,
            ErrorCorrectionLevel.Q => 62,
            ErrorCorrectionLevel.H => 74,
        },
        39 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 24,
            ErrorCorrectionLevel.M => 47,
            ErrorCorrectionLevel.Q => 65,
            ErrorCorrectionLevel.H => 77,
        },
        40 => switch (ecLevel) {
            ErrorCorrectionLevel.L => 25,
            ErrorCorrectionLevel.M => 49,
            ErrorCorrectionLevel.Q => 68,
            ErrorCorrectionLevel.H => 81,
        },
        else => unreachable,
    };
}

pub const ReedSolomonEncoder = struct {
    const Self = @This();

    gf: GaloisField,

    pub fn init(allocator: Allocator) !Self {
        const gf = try GaloisField.init(allocator);

        return Self{ .gf = gf };
    }

    pub fn deinit(self: Self) void {
        self.gf.deinit();
    }

    pub fn encode(self: Self, allocator: Allocator, msgIn: []u8, degree: usize) ![]u8 {
        const gen = try Polynomial.generateRS(allocator, self.gf, degree);
        defer gen.deinit();

        var msgOut = try allocator.alloc(u8, msgIn.len + gen.coefficients.len - 1);
        @memset(msgOut, 0);
        @memcpy(msgOut[0..msgIn.len], msgIn);

        for (0..msgIn.len) |i| {
            const coef = msgOut[i];

            if (coef == 0) {
                continue;
            }

            for (1..gen.coefficients.len) |j| {
                msgOut[i + j] ^= self.gf.mul(gen.coefficients[j], coef);
            }
        }

        std.mem.copyForwards(u8, msgOut, msgOut[msgIn.len..]);
        msgOut = try allocator.realloc(msgOut, msgOut.len - msgIn.len);
        return msgOut;
    }
};
