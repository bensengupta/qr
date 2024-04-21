const std = @import("std");

const Allocator = std.mem.Allocator;
const assert = std.debug.assert;

pub const BitMatrix = struct {
    const Self = @This();

    size: usize,
    data: []u1,

    pub fn init(allocator: Allocator, size: usize) !Self {
        const data = try allocator.alloc(u1, size * size);
        @memset(data, 0);
        return Self{ .size = size, .data = data };
    }

    pub fn deinit(self: Self, allocator: Allocator) void {
        allocator.free(self.data);
    }

    pub fn get(self: Self, row: usize, col: usize) u1 {
        return self.data[row * self.size + col];
    }

    pub fn set(self: Self, row: usize, col: usize, value: u1) void {
        assert(row < self.size);
        assert(col < self.size);
        self.data[row * self.size + col] = value;
    }

    pub fn setSquare(self: Self, row: usize, col: usize, size: usize, value: u1) void {
        for (0..size) |i| {
            for (0..size) |j| {
                self.set(row + i, col + j, value);
            }
        }
    }
};
