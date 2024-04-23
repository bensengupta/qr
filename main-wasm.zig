const std = @import("std");
const qr_code = @import("src/index.zig");
const ErrorCorrectionLevel = @import("src/error-correction.zig").ErrorCorrectionLevel;

extern fn createQRCodeCallback(matrixPtr: [*]const u8, size: usize) void;

export fn allocUint8(length: usize) [*]u8 {
    const slice = std.heap.page_allocator.alloc(u8, length) catch @panic("failed to allocate memory");

    return slice.ptr;
}

export fn freeUint8(slice: [*]const u8, length: usize) void {
    std.heap.page_allocator.free(slice[0..length]);
}

export fn createQRCode(messagePtr: [*:0]const u8, ecLevelInt: u8, qzoneSize: usize) void {
    const allocator = std.heap.page_allocator;

    const message = std.mem.span(messagePtr);
    const ecLevel: ErrorCorrectionLevel = @enumFromInt(ecLevelInt);

    const options = qr_code.CreateOptions{
        .content = message,
        .quietZoneSize = qzoneSize,
        .ecLevel = ecLevel,
    };

    const matrix = qr_code.create(allocator, options) catch @panic("failed to create QR code");
    defer matrix.deinit();

    // var buffer = std.heap.page_allocator.alloc(u8, length) catch @panic("failed to allocate memory");
    var buffer = allocUint8(matrix.size * matrix.size);

    for (0..matrix.size) |r| {
        for (0..matrix.size) |c| {
            buffer[r * matrix.size + c] = @intCast(matrix.get(r, c));
        }
    }

    createQRCodeCallback(buffer, matrix.size);
}
