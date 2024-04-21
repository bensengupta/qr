const std = @import("std");
const BitBuffer = @import("bit-buffer.zig").BitBuffer;
const versionInfo = @import("version-info.zig");
const errorCorrection = @import("error-correction.zig");

const Allocator = std.mem.Allocator;
const ErrorCorrectionLevel = errorCorrection.ErrorCorrectionLevel;

pub const ModeIndicator = enum(u4) {
    Eci = 0b0111,
    Numeric = 0b0001,
    Alphanumeric = 0b0010,
    Byte = 0b0100,
    Kanji = 0b1000,
};

const EciIndicator = struct {
    const Utf8: u8 = 26;
};

pub fn getCharCountNumBits(version: usize, modeIndicator: ModeIndicator) usize {
    return switch (modeIndicator) {
        ModeIndicator.Numeric => switch (version) {
            // Note: ranges include both ends
            1...9 => 10,
            10...26 => 12,
            27...40 => 14,
            else => unreachable,
        },
        ModeIndicator.Alphanumeric => switch (version) {
            1...9 => 9,
            10...26 => 11,
            27...40 => 13,
            else => unreachable,
        },
        ModeIndicator.Byte => switch (version) {
            1...9 => 8,
            10...26 => 16,
            27...40 => 16,
            else => unreachable,
        },
        ModeIndicator.Kanji => switch (version) {
            1...9 => 8,
            10...26 => 10,
            27...40 => 12,
            else => unreachable,
        },
        else => unreachable,
    };
}

const Segment = struct {
    const Self = @This();

    prefix: BitBuffer,
    mode: ModeIndicator,
    numChars: usize,
    data: BitBuffer,

    pub fn initEci(allocator: Allocator, data: []const u8) !Self {
        const prefix = BitBuffer.init(allocator);

        // FIXME: Temporarily disabled ECI
        // try prefix.append(u4, @intFromEnum(ModeIndicator.Eci));
        // try prefix.append(u8, EciIndicator.Utf8);

        const numChars = data.len;

        var buffer = BitBuffer.init(allocator);
        for (data) |byte| {
            try buffer.append(u8, byte);
        }

        return Self{
            .prefix = prefix,
            .mode = ModeIndicator.Byte,
            .numChars = numChars,
            .data = buffer,
        };
    }

    pub fn getLengthBits(self: Self, version: usize) usize {
        const modeBits = @bitSizeOf(@typeInfo(ModeIndicator).Enum.tag_type);
        return self.prefix.getLength() + modeBits + getCharCountNumBits(version, self.mode) + self.data.getLength();
    }

    pub fn deinit(self: Self) void {
        self.prefix.deinit();
        self.data.deinit();
    }
};

pub const Segments = struct {
    const Self = @This();

    segments: std.ArrayList(Segment),

    pub fn init(allocator: Allocator, data: []const u8) !Self {
        var segments = std.ArrayList(Segment).init(allocator);

        const segment = try Segment.initEci(allocator, data);
        try segments.append(segment);

        return Self{
            .segments = segments,
        };
    }

    pub fn deinit(self: Self) void {
        for (self.segments.items) |segment| {
            segment.deinit();
        }

        self.segments.deinit();
    }

    /// Returns the total number of bits required to encode all segments.
    pub fn getTotalBits(self: Self, version: usize) usize {
        var length: usize = 0;
        for (self.segments.items) |segment| {
            length += segment.getLengthBits(version);
        }

        return length;
    }

    pub fn assembleCodewords(self: Self, allocator: Allocator, version: usize, ecLevel: ErrorCorrectionLevel) ![]u8 {
        var buffer = BitBuffer.init(allocator);
        defer buffer.deinit();

        for (self.segments.items) |segment| {
            try buffer.extend(segment.prefix);
            try buffer.append(u4, @intFromEnum(segment.mode));
            const charCountNumBits = getCharCountNumBits(version, segment.mode);
            try buffer.appendNBits(usize, segment.numChars, charCountNumBits);
            try buffer.extend(segment.data);
        }

        const totalCodewordsCapacity = versionInfo.getTotalCodewords(version);
        const numECCodewords = errorCorrection.getErrorCorrectionCodewords(version, ecLevel);
        const dataCodewordsCapacity = totalCodewordsCapacity - numECCodewords;
        const dataBitsCapacity = dataCodewordsCapacity * 8;

        // Add terminator
        for (0..4) |_| {
            if (buffer.getLength() >= dataBitsCapacity) {
                break;
            }
            try buffer.append(u1, 0);
        }

        // Add padding bits
        const numPaddingBits = 8 - (buffer.getLength() % 8);

        for (0..numPaddingBits) |_| {
            if (buffer.getLength() >= dataBitsCapacity) {
                break;
            }
            try buffer.append(u1, 0);
        }

        // Add pad codewords
        const numPadCodewords = dataCodewordsCapacity - (buffer.getLength() / 8);
        for (0..numPadCodewords) |i| {
            if (buffer.getLength() >= dataBitsCapacity) {
                break;
            }
            const padValue: u8 = if (i % 2 == 0) 0b11101100 else 0b00010001;
            try buffer.append(u8, padValue);
        }

        const codewords = try buffer.toBytes(allocator);
        return codewords;
    }
};
