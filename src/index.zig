const std = @import("std");
const version_info = @import("version-info.zig");
const error_correction = @import("error-correction.zig");
const seg = @import("segment.zig");
const format_info = @import("format-info.zig");
const utils = @import("utils.zig");
const mask_pattern = @import("mask.zig");

const BitMatrix = @import("bit-matrix.zig").BitMatrix;
const BitBuffer = @import("bit-buffer.zig").BitBuffer;
const Blocks = @import("blocks.zig").Blocks;

const Segments = seg.Segments;

pub const ErrorCorrectionLevel = error_correction.ErrorCorrectionLevel;

const info = std.log.info;
const assert = std.debug.assert;
const Allocator = std.mem.Allocator;

const FINDER_PATTERN_SIZE = 7;
const ALIGNMENT_PATTERN_SIZE = 5;

const Error = error{
    DataTooLarge,
};

fn writeFinderPattern(pixels: BitMatrix, row: usize, col: usize) void {
    pixels.setSquare(row, col, FINDER_PATTERN_SIZE, 1);
    pixels.setSquare(row + 1, col + 1, FINDER_PATTERN_SIZE - 2, 0);
    pixels.setSquare(row + 2, col + 2, FINDER_PATTERN_SIZE - 4, 1);
}

fn writeFinderPatterns(pixels: BitMatrix, reserved: BitMatrix) void {
    // Top left
    writeFinderPattern(pixels, 0, 0);
    reserved.setSquare(0, 0, FINDER_PATTERN_SIZE + 1, 1);

    // Bottom left
    const end = pixels.size - FINDER_PATTERN_SIZE;
    writeFinderPattern(pixels, end, 0);
    reserved.setSquare(end - 1, 0, FINDER_PATTERN_SIZE + 1, 1);

    // Top right
    writeFinderPattern(pixels, 0, end);
    reserved.setSquare(0, end - 1, FINDER_PATTERN_SIZE + 1, 1);
}

fn writeAlignmentPatterns(pixels: BitMatrix, reserved: BitMatrix, version: usize) void {
    const positions = version_info.getAlignmentPositions(version);

    const patternSize = ALIGNMENT_PATTERN_SIZE;

    for (positions) |row| {
        forLoop: for (positions) |col| {
            // Ensure that the pattern does not overlap with the finder patterns
            for (0..patternSize) |i| {
                for (0..patternSize) |j| {
                    if (reserved.get(row + i, col + j) == 1) {
                        continue :forLoop;
                    }
                }
            }

            pixels.setSquare(row, col, patternSize, 1);
            pixels.setSquare(row + 1, col + 1, patternSize - 2, 0);
            pixels.setSquare(row + 2, col + 2, patternSize - 4, 1);
            reserved.setSquare(row, col, patternSize, 1);
        }
    }
}

fn reserveFormatInformation(reserved: BitMatrix) void {
    const offset = FINDER_PATTERN_SIZE + 1;
    const end = reserved.size - FINDER_PATTERN_SIZE - 1;

    for (0..(FINDER_PATTERN_SIZE + 1)) |i| {
        reserved.set(i, offset, 1);
        reserved.set(offset, i, 1);

        reserved.set(end + i, offset, 1);
        reserved.set(offset, end + i, 1);
    }

    reserved.set(offset, offset, 1);
}

fn reserveVersionInformation(reserved: BitMatrix, version: usize) void {
    if (version < 7) {
        return;
    }

    const end = reserved.size - FINDER_PATTERN_SIZE - 1 - 3;

    for (0..6) |i| {
        for (0..3) |j| {
            reserved.set(end + j, i, 1); // Bottom left
            reserved.set(i, end + j, 1); // Top right
        }
    }
}

fn writeTimingPatterns(pixels: BitMatrix, reserved: BitMatrix) void {
    const offset = FINDER_PATTERN_SIZE - 1;

    const start = FINDER_PATTERN_SIZE + 1;
    const end = pixels.size - FINDER_PATTERN_SIZE; // non-inclusive

    for (start..end) |i| {
        // Vertical
        if (reserved.get(i, offset) == 0) {
            reserved.set(i, offset, 1);
            pixels.set(i, offset, @intCast((i + 1) % 2));
        }

        // Horizontal
        if (reserved.get(offset, i) == 0) {
            reserved.set(offset, i, 1);
            pixels.set(offset, i, @intCast((i + 1) % 2));
        }
    }
}

fn writeData(pixels: BitMatrix, reserved: BitMatrix, data: BitBuffer) void {
    var index: usize = 0;
    const dataLen = data.getLength();

    // Each column is 2 pixels wide, this represents the right pixel
    var col = pixels.size - 1;
    var direction: i8 = -1;

    whileLoop: while (true) {
        // Skip the timing pattern
        if (col == FINDER_PATTERN_SIZE - 1) {
            col -= 1;
        }

        for (0..pixels.size) |row| {
            for (0..2) |dc| {
                const c = col - dc;
                const r = if (direction == -1) pixels.size - row - 1 else row;

                if (reserved.get(r, c) == 1) {
                    continue;
                }

                const bit = data.get(index);
                pixels.set(r, c, bit);
                index += 1;

                if (index >= dataLen) {
                    break :whileLoop;
                }
            }
        }

        direction = -direction;
        col -= 2;
    }
}

const FORMAT_INFO_MASK: u15 = 0b101010000010010;

fn writeFormatInformation(pixels: BitMatrix, ecLevel: ErrorCorrectionLevel, maskPattern: u3) void {
    var format: u5 = 0;
    format |= @as(u5, @intFromEnum(ecLevel)) << 3;
    format |= @as(u5, maskPattern);

    var encoded = format_info.encodeFormatInfo(format);
    encoded ^= FORMAT_INFO_MASK;

    var bits = [_]u1{0} ** 15;
    utils.splitIntoBits(u15, encoded, &bits);

    // ========= Top left =========
    var index: usize = 0;
    for (0..6) |i| {
        pixels.set(8, i, bits[index]);
        index += 1;
    }

    pixels.set(8, 7, bits[index]);
    index += 1;
    pixels.set(8, 8, bits[index]);
    index += 1;
    pixels.set(7, 8, bits[index]);
    index += 1;

    for (0..6) |i| {
        pixels.set(5 - i, 8, bits[index]);
        index += 1;
    }

    // ========= Other corners =========
    index = 0;
    for (0..7) |i| {
        pixels.set(pixels.size - 1 - i, 8, bits[index]);
        index += 1;
    }

    pixels.set(pixels.size - 8, 8, 1);

    for (0..8) |i| {
        pixels.set(8, pixels.size - 8 + i, bits[index]);
        index += 1;
    }
}

fn writeVersionInformation(pixels: BitMatrix, version: usize) void {
    if (version < 7) {
        return;
    }

    const encoded = version_info.encodeVersionInfo(@intCast(version));

    var bits = [_]u1{0} ** 18;
    utils.splitIntoBits(u18, encoded, &bits);

    for (0..6) |i| {
        for (0..3) |j| {
            // Lower left
            pixels.set(pixels.size - 11 + j, i, bits[bits.len - 1 - (i * 3 + j)]);
            // Upper right
            pixels.set(i, pixels.size - 11 + j, bits[bits.len - 1 - (i * 3 + j)]);
        }
    }
}

fn getBestVersion(segments: Segments, ecLevel: ErrorCorrectionLevel) Error!usize {
    for (1..41) |version| {
        const totalDataBits = segments.getTotalBits(version);
        const totalDataCodewords = (totalDataBits + 7) / 8; // + 7 to round up

        const totalCodewordsCapacity = version_info.getTotalCodewords(version);
        const numECCodewords = error_correction.getErrorCorrectionCodewords(version, ecLevel);
        const availableDataCodeWords = totalCodewordsCapacity - numECCodewords;

        if (totalDataCodewords <= availableDataCodeWords) {
            return version;
        }
    }

    return Error.DataTooLarge;
}

fn encodeData(allocator: Allocator, version: usize, segments: Segments, ecLevel: ErrorCorrectionLevel) !BitBuffer {
    const dataCodewords = try segments.assembleCodewords(allocator, version, ecLevel);
    defer allocator.free(dataCodewords);

    const totalCodewords = version_info.getTotalCodewords(version);
    const totalECCodewords = error_correction.getErrorCorrectionCodewords(version, ecLevel);
    const totalDataCodewords = totalCodewords - totalECCodewords;

    assert(totalDataCodewords == dataCodewords.len);

    const numECBlocks = error_correction.getErrorCorrectionBlocks(version, ecLevel);

    const blocksInGroup2 = totalCodewords % numECBlocks;
    const blocksInGroup1 = numECBlocks - blocksInGroup2;

    const totalCodewordsInGroup1 = totalCodewords / numECBlocks;

    const dataCodewordsInGroup1 = totalDataCodewords / numECBlocks;
    const dataCodewordsInGroup2 = dataCodewordsInGroup1 + 1;

    const ecCount = totalCodewordsInGroup1 - dataCodewordsInGroup1;

    var blocks = try Blocks.init(allocator);
    defer blocks.deinit();

    const rs = try error_correction.ReedSolomonEncoder.init(allocator);
    defer rs.deinit();

    var offset: usize = 0;
    for (0..numECBlocks) |b| {
        const dataSize = if (b < blocksInGroup1) dataCodewordsInGroup1 else dataCodewordsInGroup2;

        const blockDCData = dataCodewords[offset..(offset + dataSize)];

        try blocks.writeDCBlock(blockDCData);

        const blockECData = try rs.encode(allocator, blockDCData, ecCount);
        defer allocator.free(blockECData);

        try blocks.writeECBlock(blockECData);
        offset += dataSize;
    }

    const interleaved = try blocks.interleave(allocator);

    return interleaved;
}

pub fn create(allocator: Allocator, ecLevel: ErrorCorrectionLevel, content: [:0]const u8) !BitMatrix {
    const segments = try Segments.init(allocator, content);
    defer segments.deinit();

    const version = try getBestVersion(segments, ecLevel);

    const dataBits = try encodeData(allocator, version, segments, ecLevel);
    defer dataBits.deinit();

    const matrixSize = version_info.getMatrixSize(version);

    const pixels = try BitMatrix.init(allocator, matrixSize);

    const reserved = try BitMatrix.init(allocator, matrixSize);
    defer reserved.deinit();

    writeFinderPatterns(pixels, reserved);
    writeAlignmentPatterns(pixels, reserved, version);
    writeTimingPatterns(pixels, reserved);
    reserveFormatInformation(reserved);
    reserveVersionInformation(reserved, version);

    writeData(pixels, reserved, dataBits);

    const maskPattern = mask_pattern.applyBestPattern(pixels, reserved);

    writeFormatInformation(pixels, ecLevel, maskPattern);
    writeVersionInformation(pixels, version);

    return pixels;
}

test "no memory leaks" {
    const allocator = std.testing.allocator;

    const content = "Hello, world!";
    const ecLevel = ErrorCorrectionLevel.M;

    const matrix = try create(allocator, ecLevel, content);
    defer matrix.deinit();
}
