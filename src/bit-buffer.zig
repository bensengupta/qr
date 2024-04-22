const std = @import("std");

const Allocator = std.mem.Allocator;
const assert = std.debug.assert;

pub const BitBuffer = struct {
    const Self = @This();

    arrayList: std.ArrayList(u1),

    pub fn init(allocator: Allocator) Self {
        const arrayList = std.ArrayList(u1).init(allocator);

        return Self{
            .arrayList = arrayList,
        };
    }

    pub fn deinit(self: Self) void {
        self.arrayList.deinit();
    }

    pub fn get(self: Self, index: usize) u1 {
        return self.arrayList.items[index];
    }

    pub fn getLength(self: Self) usize {
        return self.arrayList.items.len;
    }

    pub fn append(self: *Self, comptime T: type, value: T) !void {
        var val = value;
        const numBits = @bitSizeOf(T);

        if (numBits == 1) {
            try self.arrayList.append(val);
            return;
        }

        const leftmostBitMask: T = @intCast(1 << (numBits - 1));
        for (0..numBits) |_| {
            // Push the leftmost bit
            const leftmostBit: u1 = @intCast(val / leftmostBitMask);
            try self.arrayList.append(leftmostBit);
            val = (val % leftmostBitMask) << 1;
        }
    }

    pub fn appendNBits(self: *Self, comptime T: type, value: T, numBits: usize) !void {
        var val = value;
        var reversed: T = 0;

        for (0..numBits) |_| {
            reversed = (reversed << 1) | (val & 1);
            val >>= 1;
        }

        for (0..numBits) |_| {
            const bit: u1 = @intCast(reversed & 1);
            try self.arrayList.append(bit);
            reversed >>= 1;
        }
    }

    pub fn extend(self: *Self, otherBuffer: BitBuffer) !void {
        for (0..otherBuffer.getLength()) |i| {
            try self.arrayList.append(otherBuffer.get(i));
        }
    }

    /// Note: Must have a length that is a multiple of 8
    pub fn toBytes(self: Self, allocator: Allocator) ![]u8 {
        assert(self.arrayList.items.len % 8 == 0);

        const numBytes = self.arrayList.items.len / 8;
        const bytes = try allocator.alloc(u8, numBytes);

        for (0..numBytes) |byteIndex| {
            var byte: u8 = 0;
            for (0..8) |bitIndex| {
                const bit: u8 = @intCast(self.get(byteIndex * 8 + bitIndex));
                const shift: u3 = @intCast(7 - bitIndex);
                byte |= bit << shift;
            }
            bytes[byteIndex] = byte;
        }

        return bytes;
    }
};
