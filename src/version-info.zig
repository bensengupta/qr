pub fn getMatrixSize(version: usize) usize {
    return switch (version) {
        1 => 21,
        2 => 25,
        3 => 29,
        4 => 33,
        5 => 37,
        6 => 41,
        7 => 45,
        8 => 49,
        9 => 53,
        10 => 57,
        11 => 61,
        12 => 65,
        13 => 69,
        14 => 73,
        15 => 77,
        16 => 81,
        17 => 85,
        18 => 89,
        19 => 93,
        20 => 97,
        21 => 101,
        22 => 105,
        23 => 109,
        24 => 113,
        25 => 117,
        26 => 121,
        27 => 125,
        28 => 129,
        29 => 133,
        30 => 137,
        31 => 141,
        32 => 145,
        33 => 149,
        34 => 153,
        35 => 157,
        36 => 161,
        37 => 165,
        38 => 169,
        39 => 173,
        40 => 177,
        else => unreachable,
    };
}

const ALIGNMENT_POSITIONS_1 = [_]usize{};
const ALIGNMENT_POSITIONS_2 = [_]usize{ 4, 16 };
const ALIGNMENT_POSITIONS_3 = [_]usize{ 4, 20 };
const ALIGNMENT_POSITIONS_4 = [_]usize{ 4, 24 };
const ALIGNMENT_POSITIONS_5 = [_]usize{ 4, 28 };
const ALIGNMENT_POSITIONS_6 = [_]usize{ 4, 32 };
const ALIGNMENT_POSITIONS_7 = [_]usize{ 4, 20, 36 };
const ALIGNMENT_POSITIONS_8 = [_]usize{ 4, 22, 40 };
const ALIGNMENT_POSITIONS_9 = [_]usize{ 4, 24, 44 };
const ALIGNMENT_POSITIONS_10 = [_]usize{ 4, 26, 48 };
const ALIGNMENT_POSITIONS_11 = [_]usize{ 4, 28, 52 };
const ALIGNMENT_POSITIONS_12 = [_]usize{ 4, 30, 56 };
const ALIGNMENT_POSITIONS_13 = [_]usize{ 4, 32, 60 };
const ALIGNMENT_POSITIONS_14 = [_]usize{ 4, 24, 44, 64 };
const ALIGNMENT_POSITIONS_15 = [_]usize{ 4, 24, 46, 68 };
const ALIGNMENT_POSITIONS_16 = [_]usize{ 4, 24, 48, 72 };
const ALIGNMENT_POSITIONS_17 = [_]usize{ 4, 28, 52, 76 };
const ALIGNMENT_POSITIONS_18 = [_]usize{ 4, 28, 54, 80 };
const ALIGNMENT_POSITIONS_19 = [_]usize{ 4, 28, 56, 84 };
const ALIGNMENT_POSITIONS_20 = [_]usize{ 4, 32, 60, 88 };
const ALIGNMENT_POSITIONS_21 = [_]usize{ 4, 26, 48, 70, 92 };
const ALIGNMENT_POSITIONS_22 = [_]usize{ 4, 24, 48, 72, 96 };
const ALIGNMENT_POSITIONS_23 = [_]usize{ 4, 28, 52, 76, 100 };
const ALIGNMENT_POSITIONS_24 = [_]usize{ 4, 26, 52, 78, 104 };
const ALIGNMENT_POSITIONS_25 = [_]usize{ 4, 30, 56, 82, 108 };
const ALIGNMENT_POSITIONS_26 = [_]usize{ 4, 28, 56, 84, 112 };
const ALIGNMENT_POSITIONS_27 = [_]usize{ 4, 32, 60, 88, 116 };
const ALIGNMENT_POSITIONS_28 = [_]usize{ 4, 24, 48, 72, 96, 120 };
const ALIGNMENT_POSITIONS_29 = [_]usize{ 4, 28, 52, 76, 100, 124 };
const ALIGNMENT_POSITIONS_30 = [_]usize{ 4, 24, 50, 76, 102, 128 };
const ALIGNMENT_POSITIONS_31 = [_]usize{ 4, 28, 54, 80, 106, 132 };
const ALIGNMENT_POSITIONS_32 = [_]usize{ 4, 32, 58, 84, 110, 136 };
const ALIGNMENT_POSITIONS_33 = [_]usize{ 4, 28, 56, 84, 112, 140 };
const ALIGNMENT_POSITIONS_34 = [_]usize{ 4, 32, 60, 88, 116, 144 };
const ALIGNMENT_POSITIONS_35 = [_]usize{ 4, 28, 52, 76, 100, 124, 148 };
const ALIGNMENT_POSITIONS_36 = [_]usize{ 4, 22, 48, 74, 100, 126, 152 };
const ALIGNMENT_POSITIONS_37 = [_]usize{ 4, 26, 52, 78, 104, 130, 156 };
const ALIGNMENT_POSITIONS_38 = [_]usize{ 4, 30, 56, 82, 108, 134, 160 };
const ALIGNMENT_POSITIONS_39 = [_]usize{ 4, 24, 52, 80, 108, 136, 164 };
const ALIGNMENT_POSITIONS_40 = [_]usize{ 4, 28, 56, 84, 112, 140, 168 };

/// Returns the top-left corner positions of the alignment patterns for the given version.
pub fn getAlignmentPositions(version: usize) []const usize {
    return switch (version) {
        1 => &ALIGNMENT_POSITIONS_1,
        2 => &ALIGNMENT_POSITIONS_2,
        3 => &ALIGNMENT_POSITIONS_3,
        4 => &ALIGNMENT_POSITIONS_4,
        5 => &ALIGNMENT_POSITIONS_5,
        6 => &ALIGNMENT_POSITIONS_6,
        7 => &ALIGNMENT_POSITIONS_7,
        8 => &ALIGNMENT_POSITIONS_8,
        9 => &ALIGNMENT_POSITIONS_9,
        10 => &ALIGNMENT_POSITIONS_10,
        11 => &ALIGNMENT_POSITIONS_11,
        12 => &ALIGNMENT_POSITIONS_12,
        13 => &ALIGNMENT_POSITIONS_13,
        14 => &ALIGNMENT_POSITIONS_14,
        15 => &ALIGNMENT_POSITIONS_15,
        16 => &ALIGNMENT_POSITIONS_16,
        17 => &ALIGNMENT_POSITIONS_17,
        18 => &ALIGNMENT_POSITIONS_18,
        19 => &ALIGNMENT_POSITIONS_19,
        20 => &ALIGNMENT_POSITIONS_20,
        21 => &ALIGNMENT_POSITIONS_21,
        22 => &ALIGNMENT_POSITIONS_22,
        23 => &ALIGNMENT_POSITIONS_23,
        24 => &ALIGNMENT_POSITIONS_24,
        25 => &ALIGNMENT_POSITIONS_25,
        26 => &ALIGNMENT_POSITIONS_26,
        27 => &ALIGNMENT_POSITIONS_27,
        28 => &ALIGNMENT_POSITIONS_28,
        29 => &ALIGNMENT_POSITIONS_29,
        30 => &ALIGNMENT_POSITIONS_30,
        31 => &ALIGNMENT_POSITIONS_31,
        32 => &ALIGNMENT_POSITIONS_32,
        33 => &ALIGNMENT_POSITIONS_33,
        34 => &ALIGNMENT_POSITIONS_34,
        35 => &ALIGNMENT_POSITIONS_35,
        36 => &ALIGNMENT_POSITIONS_36,
        37 => &ALIGNMENT_POSITIONS_37,
        38 => &ALIGNMENT_POSITIONS_38,
        39 => &ALIGNMENT_POSITIONS_39,
        40 => &ALIGNMENT_POSITIONS_40,
        else => unreachable,
    };
}

pub fn getTotalCodewords(version: usize) usize {
    return switch (version) {
        1 => 26,
        2 => 44,
        3 => 70,
        4 => 100,
        5 => 134,
        6 => 172,
        7 => 196,
        8 => 242,
        9 => 292,
        10 => 346,
        11 => 404,
        12 => 466,
        13 => 532,
        14 => 581,
        15 => 655,
        16 => 733,
        17 => 815,
        18 => 901,
        19 => 991,
        20 => 1085,
        21 => 1156,
        22 => 1258,
        23 => 1364,
        24 => 1474,
        25 => 1588,
        26 => 1706,
        27 => 1828,
        28 => 1921,
        29 => 2051,
        30 => 2185,
        31 => 2323,
        32 => 2465,
        33 => 2611,
        34 => 2761,
        35 => 2876,
        36 => 3034,
        37 => 3196,
        38 => 3362,
        39 => 3532,
        40 => 3706,
        else => unreachable,
    };
}

const VERSION_INFO_GENERATOR: u18 = 0x1f25;

pub fn encodeVersionInfo(formatInfo: u6) u18 {
    const fmt = @as(u18, formatInfo) << 12;
    var result = fmt;

    for (0..6) |i| {
        const shift: u5 = @intCast(i);
        const mask: u18 = @as(u18, 1) << (17 - shift);

        if (result & mask != 0) {
            result ^= VERSION_INFO_GENERATOR << (5 - shift);
        }
    }

    return result | fmt;
}
