const std = @import("std");
const versionInfo = @import("version-info.zig");
const errorCorrection = @import("error-correction.zig");
const BitBuffer = @import("bit-buffer.zig").BitBuffer;

const assert = std.debug.assert;
const Allocator = std.mem.Allocator;

pub const Blocks = struct {
    const Self = @This();

    allocator: Allocator,
    numBlocks: usize,
    dcPerBlock: usize,
    ecPerBlock: usize,
    dcData: []u8,
    ecData: []u8,

    pub fn init(
        allocator: Allocator,
        numBlocks: usize,
        dcPerBlock: usize,
        ecPerBlock: usize,
    ) !Self {
        return Self{
            .allocator = allocator,
            .numBlocks = numBlocks,
            .dcPerBlock = dcPerBlock,
            .ecPerBlock = ecPerBlock,
            .dcData = try allocator.alloc(u8, numBlocks * dcPerBlock),
            .ecData = try allocator.alloc(u8, numBlocks * ecPerBlock),
        };
    }

    pub fn deinit(self: Self) void {
        self.allocator.free(self.dcData);
        self.allocator.free(self.ecData);
    }

    pub fn writeDCBlocks(self: Self, data: []u8) void {
        assert(data.len == self.numBlocks * self.dcPerBlock);
        @memcpy(self.dcData, data);
    }

    pub fn writeECBlock(self: Self, blockIndex: usize, data: []u8) void {
        assert(blockIndex < self.numBlocks);
        assert(data.len == self.ecPerBlock);

        const start = blockIndex * self.ecPerBlock;
        const end = (blockIndex + 1) * self.ecPerBlock;

        @memcpy(self.ecData[start..end], data);
    }

    pub fn getDCBlockSlice(self: Self, blockIndex: usize) []u8 {
        const start = blockIndex * self.dcPerBlock;
        const end = (blockIndex + 1) * self.dcPerBlock;
        return self.dcData[start..end];
    }

    pub fn interleave(self: Self, allocator: Allocator) !BitBuffer {
        var buffer = BitBuffer.init(allocator);

        for (0..self.dcPerBlock) |j| {
            for (0..self.numBlocks) |i| {
                const dataCodeword = self.dcData[i * self.dcPerBlock + j];
                try buffer.append(u8, dataCodeword);
            }
        }

        for (0..self.ecPerBlock) |j| {
            for (0..self.numBlocks) |i| {
                const ecCodeword = self.ecData[i * self.ecPerBlock + j];
                try buffer.append(u8, ecCodeword);
            }
        }

        return buffer;
    }
};
