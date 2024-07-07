const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "qr",
        .root_source_file = b.path("main-cli.zig"),
        .target = b.standardTargetOptions(.{}),
        .optimize = optimize,
    });
    b.installArtifact(exe);

    const wasm = b.addExecutable(.{
        .name = "qr",
        .root_source_file = b.path("main-wasm.zig"),
        .target = b.resolveTargetQuery(.{ .cpu_arch = .wasm32, .os_tag = .freestanding }),
        .optimize = optimize,
    });
    wasm.entry = .disabled;
    wasm.rdynamic = true;

    const wasmInstall = b.addInstallArtifact(wasm, .{
        .dest_dir = .{ .override = .prefix },
    });

    const wasmStep = b.step("wasm", "Build wasm module");
    wasmStep.dependOn(&wasmInstall.step);
}
