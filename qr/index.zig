const std = @import("std");
const versionInfo = @import("version-info.zig");
const errorCorrection = @import("error-correction.zig");
const seg = @import("segment.zig");
const BitMatrix = @import("bit-matrix.zig").BitMatrix;
const ansiRenderer = @import("ansi-renderer.zig");

const Segments = seg.Segments;

pub const ErrorCorrectionLevel = errorCorrection.ErrorCorrectionLevel;

const info = std.log.info;
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
    const positions = versionInfo.getAlignmentPositions(version);

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

fn getBestVersion(segments: Segments, ecLevel: ErrorCorrectionLevel) Error!usize {
    for (1..41) |version| {
        const totalDataBits = segments.getTotalBits(version);
        const totalDataCodewords = totalDataBits / 8;

        const totalCodewordsCapacity = versionInfo.getTotalCodewords(version);
        const numECCodewords = errorCorrection.getErrorCorrectionCodewords(version, ecLevel);
        const availableDataCodeWords = totalCodewordsCapacity - numECCodewords;

        if (totalDataCodewords <= availableDataCodeWords) {
            return version;
        }
    }

    return Error.DataTooLarge;
}

fn encodeData(allocator: Allocator, ecLevel: ErrorCorrectionLevel, content: [:0]u8) !void {
    const segments = try Segments.init(allocator, content);
    defer segments.deinit();

    const version = try getBestVersion(segments, ecLevel);

    const dataCodewords = try segments.assembleCodewords(allocator, version, ecLevel);
    defer allocator.free(dataCodewords);

    info("best version = {}", .{version});
    info("codewords = {any}", .{dataCodewords});
}

pub fn make(allocator: Allocator, ecLevel: ErrorCorrectionLevel, content: [:0]u8) !void {
    const version = 3;
    const canvasSize = versionInfo.getMatrixSize(version);

    const pixels = try BitMatrix.init(allocator, canvasSize);
    const reserved = try BitMatrix.init(allocator, canvasSize);
    defer pixels.deinit(allocator);
    defer reserved.deinit(allocator);

    writeFinderPatterns(pixels, reserved);
    writeAlignmentPatterns(pixels, reserved, version);
    writeTimingPatterns(pixels, reserved);
    reserveFormatInformation(reserved);
    reserveVersionInformation(reserved, version);

    try encodeData(allocator, ecLevel, content);

    try ansiRenderer.renderBlue(reserved);
    try ansiRenderer.render(pixels);
}
