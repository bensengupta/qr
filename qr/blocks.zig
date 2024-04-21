const std = @import("std");
const versionInfo = @import("version-info.zig");
const errorCorrection = @import("error-correction.zig");
const BitBuffer = @import("bit-buffer.zig").BitBuffer;

const assert = std.debug.assert;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

pub const Blocks = struct {
    const Self = @This();

    allocator: Allocator,
    dcData: ArrayList([]u8),
    ecData: ArrayList([]u8),

    pub fn init(
        allocator: Allocator,
    ) !Self {
        return Self{
            .allocator = allocator,
            .dcData = ArrayList([]u8).init(allocator),
            .ecData = ArrayList([]u8).init(allocator),
        };
    }

    pub fn deinit(self: Self) void {
        for (self.dcData.items) |block| {
            self.allocator.free(block);
        }
        for (self.ecData.items) |block| {
            self.allocator.free(block);
        }
        self.dcData.deinit();
        self.ecData.deinit();
    }

    pub fn writeDCBlock(self: *Self, data: []u8) !void {
        const block = try self.allocator.alloc(u8, data.len);
        @memcpy(block, data);
        try self.dcData.append(block);
    }

    pub fn writeECBlock(self: *Self, data: []u8) !void {
        const block = try self.allocator.alloc(u8, data.len);
        @memcpy(block, data);
        try self.ecData.append(block);
    }

    pub fn interleave(self: Self, allocator: Allocator) !BitBuffer {
        assert(self.dcData.items.len >= 1);
        assert(self.dcData.items.len == self.ecData.items.len);

        const numBlocks = self.dcData.items.len;

        var buffer = BitBuffer.init(allocator);

        var maxDataSize: usize = 0;
        for (self.dcData.items) |dcBlock| {
            maxDataSize = @max(maxDataSize, dcBlock.len);
        }

        for (0..maxDataSize) |j| {
            for (0..numBlocks) |i| {
                if (j < self.dcData.items[i].len) {
                    const dataCodeword = self.dcData.items[i][j];
                    try buffer.append(u8, dataCodeword);
                }
            }
        }

        const ecCount = self.ecData.items[0].len;

        for (0..ecCount) |j| {
            for (0..numBlocks) |i| {
                const ecCodeword = self.ecData.items[i][j];
                try buffer.append(u8, ecCodeword);
            }
        }

        return buffer;
    }
};
