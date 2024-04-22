const std = @import("std");
const ErrorCorrectionLevel = @import("error-correction.zig").ErrorCorrectionLevel;

fn printUsage() void {
    const stderr = std.io.getStdErr().writer();
    const usageString =
        \\Usage: qr-encode [options] <message>
        \\
        \\QR Code options:
        \\  -e, --error     Error correction level       ["L", "M", "Q", "H"]
        \\
        \\Options:
        \\  -h, --help      Show help
        \\
        \\Examples:
        \\  qr-encode "some text"
        \\  qr-encode -e H "some text"
        \\
    ;

    stderr.print(usageString, .{}) catch {};
}

fn exitWithErrorMessage(message: [:0]const u8) noreturn {
    const stderr = std.io.getStdErr().writer();
    stderr.print("error: {s}, see --help for usage\n", .{message}) catch {};
    std.process.exit(1);
}

fn strEq(arg: [:0]const u8, str: [:0]const u8) bool {
    return std.mem.eql(u8, arg, str);
}

pub const CliOptions = struct {
    const Self = @This();

    message: [:0]const u8,
    ecLevel: ErrorCorrectionLevel,

    fn parseECLevel(args: [][:0]const u8, i: *usize, ecLevel: *?ErrorCorrectionLevel) void {
        if (ecLevel.* != null) {
            exitWithErrorMessage("duplicate argument for -e");
        }

        i.* += 1;
        if (i.* >= args.len) {
            exitWithErrorMessage("missing argument for -e");
        }

        const arg = args[i.*];

        if (arg.len != 1) {
            exitWithErrorMessage("invalid argument for -e");
        }

        switch (arg[0]) {
            'L' => ecLevel.* = ErrorCorrectionLevel.L,
            'M' => ecLevel.* = ErrorCorrectionLevel.M,
            'Q' => ecLevel.* = ErrorCorrectionLevel.Q,
            'H' => ecLevel.* = ErrorCorrectionLevel.H,
            else => exitWithErrorMessage("invalid argument for -e"),
        }
    }

    fn parseMessage(args: [][:0]const u8, i: *usize, message: *?[:0]const u8) void {
        if (message.* != null) {
            exitWithErrorMessage("duplicate message argument");
        }
        message.* = args[i.*];
    }

    pub fn parseArgs(args: [][:0]const u8) Self {
        var ecLevel: ?ErrorCorrectionLevel = null;
        var message: ?[:0]const u8 = null;

        var i: usize = 1;
        while (i < args.len) : (i += 1) {
            const arg = args[i];

            if (strEq(arg, "-h") or strEq(arg, "--help")) {
                printUsage();
                std.process.exit(0);
            }

            if (strEq(arg, "-e") or strEq(arg, "--error")) {
                parseECLevel(args, &i, &ecLevel);
                continue;
            }

            parseMessage(args, &i, &message);
        }

        if (ecLevel == null) {
            ecLevel = ErrorCorrectionLevel.M;
        }

        if (message == null) {
            exitWithErrorMessage("missing message");
        }

        return CliOptions{ .ecLevel = ecLevel.?, .message = message.? };
    }
};
