const std = @import("std");
const CreateOptions = @import("index.zig").CreateOptions;
const ErrorCorrectionLevel = @import("error-correction.zig").ErrorCorrectionLevel;

fn printUsage() void {
    const stderr = std.io.getStdErr().writer();
    const usageString =
        \\Usage: qr [options] <message>
        \\
        \\QR Code options:
        \\  -e, --error     Error correction level       ["L", "M", "Q", "H"]
        \\  -q, --qzone     Quiet zone size                         [integer]
        \\
        \\Options:
        \\  -h, --help      Show help
        \\
        \\Examples:
        \\  qr "some text"
        \\  qr -e H "some text"
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

fn parseQuietZoneSize(args: [][:0]const u8, i: *usize, quietZoneSize: *?usize) void {
    if (quietZoneSize.* != null) {
        exitWithErrorMessage("duplicate argument for -q");
    }

    i.* += 1;
    if (i.* >= args.len) {
        exitWithErrorMessage("missing argument for -q");
    }

    const arg = args[i.*];

    const parsedQzone = std.fmt.parseInt(usize, arg, 10) catch exitWithErrorMessage("invalid argument for -q");
    quietZoneSize.* = parsedQzone;
}

pub fn parseCliArgs(args: [][:0]const u8) CreateOptions {
    var message: ?[:0]const u8 = null;
    var ecLevel: ?ErrorCorrectionLevel = null;
    var quietZoneSize: ?usize = null;

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

        if (strEq(arg, "-q") or strEq(arg, "--qzone")) {
            parseQuietZoneSize(args, &i, &quietZoneSize);
            continue;
        }

        parseMessage(args, &i, &message);
    }

    if (message == null) {
        exitWithErrorMessage("missing message");
    }

    var options = CreateOptions{ .content = message.? };

    if (ecLevel) |ec| {
        options.ecLevel = ec;
    }

    if (quietZoneSize) |qzone| {
        options.quietZoneSize = qzone;
    }

    return options;
}
