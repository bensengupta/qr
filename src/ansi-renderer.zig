const std = @import("std");
const BitMatrix = @import("bit-matrix.zig").BitMatrix;

const ANSIColors = struct {
    const Reset = "\u{001B}[0m";
    const BgBlack = "\u{001B}[40m";
    const BgWhite = "\u{001B}[47m";
};

pub fn render(matrix: BitMatrix) !void {
    try printMatrix(matrix, ANSIColors.BgBlack, ANSIColors.BgWhite);
}

fn printMatrix(matrix: BitMatrix, trueColor: []const u8, falseColor: []const u8) !void {
    const stdout = std.io.getStdOut().writer();

    for (0..matrix.size) |r| {
        for (0..matrix.size) |c| {
            const value = matrix.get(r, c);
            const color = if (value == 1) trueColor else falseColor;
            try stdout.print("{s}  {s}", .{ color, ANSIColors.Reset });
        }

        try stdout.print("\n", .{});
    }
}
