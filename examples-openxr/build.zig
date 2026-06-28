const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "dummy",
        .root_module = b.createModule(.{
            .root_source_file = b.path("dummy.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .imports = &.{.{
                .name = "openxr",
                .module = b.dependency("openxr", .{
                    .registry = b.path("xr.xml"),
                }).module("openxr-zig"),
            }},
        }),
    });

    exe.root_module.linkSystemLibrary("openxr_loader", .{});

    b.installArtifact(exe);
}
