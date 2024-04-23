const std = @import("std");
const qr_code = @import("src/index.zig");
const ansi_renderer = @import("src/ansi-renderer.zig");

const cli = @import("src/cli.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const options = cli.parseCliArgs(args);

    const matrix = try qr_code.create(allocator, options);
    defer matrix.deinit();

    try ansi_renderer.render(matrix);
}
