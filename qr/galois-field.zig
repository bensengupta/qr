const std = @import("std");

const Allocator = std.mem.Allocator;

const PRIME = 0x11d;

// Based off of "Reed-Solomon codes for coders" - Wikiversity.org
// https://en.wikiversity.org/wiki/Reed%E2%80%93Solomon_codes_for_coders
pub const GaloisField = struct {
    const Self = @This();

    exp: []u8,
    log: []u8,

    pub fn init(allocator: Allocator) !Self {
        var exp = try allocator.alloc(u8, 512);
        var log = try allocator.alloc(u8, 256);

        var x: usize = 1;
        for (0..255) |i| {
            exp[i] = @intCast(x); // cast to u8
            log[x] = @intCast(i);
            x <<= 1;
            if (x & 0x100 != 0) {
                x ^= PRIME;
            }
        }

        for (255..512) |i| {
            exp[i] = exp[i - 255];
        }

        return Self{ .exp = exp, .log = log };
    }

    pub fn deinit(self: Self, allocator: Allocator) void {
        allocator.free(self.exp);
        allocator.free(self.log);
    }

    pub fn mul(self: Self, a: u8, b: u8) u8 {
        if (a == 0 or b == 0) {
            return 0;
        }

        var sum: usize = 0;
        sum += @intCast(self.log[a]);
        sum += @intCast(self.log[b]);
        return self.exp[sum];
    }

    pub fn pow(self: Self, x: u8, power: usize) u8 {
        return self.exp[(power * self.log[x]) % 255];
    }
};

pub const Polynomial = struct {
    const Self = @This();

    coefficients: []u8,

    fn init(allocator: Allocator, degree: usize) !Self {
        const coefficients = try allocator.alloc(u8, degree);
        return Self{ .coefficients = coefficients };
    }

    pub fn deinit(self: Self, allocator: Allocator) void {
        allocator.free(self.coefficients);
    }

    fn mul(allocator: Allocator, gf: GaloisField, p: Self, q: Self) !Self {
        const newSize = p.coefficients.len + q.coefficients.len - 1;
        const result = try Self.init(allocator, newSize);
        @memset(result.coefficients, 0);

        for (0..q.coefficients.len) |j| {
            for (0..p.coefficients.len) |i| {
                result.coefficients[i + j] ^= gf.mul(p.coefficients[i], q.coefficients[j]);
            }
        }

        return result;
    }

    pub fn generateRS(allocator: Allocator, gf: GaloisField, degree: usize) !Self {
        var gen = try Self.init(allocator, 1);
        gen.coefficients[0] = 1;

        for (0..degree) |i| {
            var coeff = [_]u8{ 1, gf.pow(2, i) };
            const poly2 = Self{ .coefficients = &coeff };

            const newGen = try Self.mul(allocator, gf, gen, poly2);

            gen.deinit(allocator);
            gen = newGen;
        }

        return gen;
    }
};
