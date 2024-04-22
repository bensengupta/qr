const std = @import("std");
const QrCode = @import("qr/index.zig");

const Allocator = std.mem.Allocator;
const assert = std.debug.assert;

fn printUsageAndExit(args: [][:0]u8) !void {
    const stderr = std.io.getStdErr().writer();
    try stderr.print("Usage: {s} [options] <message>\n", .{args[0]});
    try stderr.print("  -e <level>: Specify error correction level ('L', 'M', 'Q', or 'H'), default: 'L'\n", .{});
    std.process.exit(1);
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const str = try allocator.alloc(u8, 20);
    _ = try std.fmt.bufPrint(str, "Hello, World!", .{});

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        try printUsageAndExit(args);
    }

    var errorCorrectionLevel = QrCode.ErrorCorrectionLevel.L;
    var message: ?[:0]u8 = null;

    var i: usize = 1;
    while (i < args.len) : (i += 1) {
        var arg = args[i];

        if (std.mem.eql(u8, arg, "-e")) {
            i += 1;

            if (i >= args.len) {
                try printUsageAndExit(args);
            }

            arg = args[i];

            if (std.mem.eql(u8, arg, "L")) {
                errorCorrectionLevel = QrCode.ErrorCorrectionLevel.L;
                continue;
            }
            if (std.mem.eql(u8, arg, "M")) {
                errorCorrectionLevel = QrCode.ErrorCorrectionLevel.M;
                continue;
            }
            if (std.mem.eql(u8, arg, "Q")) {
                errorCorrectionLevel = QrCode.ErrorCorrectionLevel.Q;
                continue;
            }
            if (std.mem.eql(u8, arg, "H")) {
                errorCorrectionLevel = QrCode.ErrorCorrectionLevel.H;
                continue;
            }

            try printUsageAndExit(args);
        }

        if (message != null) {
            try printUsageAndExit(args);
        }

        message = arg;
    }

    if (message == null) {
        try printUsageAndExit(args);
    }

    try QrCode.make(allocator, errorCorrectionLevel, message.?);
}
