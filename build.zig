const std = @import("std");

pub fn build(b: *std.Build) void {
    // https://wiki.osdev.org/Zig_Bare_Bones
    const target_query_bootloader = std.Target.Query{
        .cpu_arch = .aarch64, 
        .os_tag = .uefi,
        .abi = .none,
    };

    const target_query_kernel = std.Target.Query{
        .cpu_arch = .aarch64,
        .os_tag = .freestanding,
        .abi = .none,
    };

    const target_bl = b.resolveTargetQuery(target_query_bootloader);
    const target_k = b.resolveTargetQuery(target_query_kernel);

    const optimize = b.standardOptimizeOption(.{});

    const efi = b.addExecutable(.{
        .name = "boot_arm64",
        .root_source_file = b.path("src/bootloader/main.zig"),
        .target = target_bl,
        .optimize = optimize,
    });
    // efi.entry = .{.symbol_name = "EfiMain"};
    efi.subsystem = .EfiApplication;
    var efi_install_step = b.addInstallArtifact(efi, .{});

    const unit_tests = b.addTest(.{
        .root_source_file = b.path("src/bootloader/status.zig"),
        .target = b.standardTargetOptions(.{}),
    });
    const run_unit_tests = b.addRunArtifact(unit_tests);

    const kernel = b.addExecutable(.{
        .name = "kernel",
        .root_source_file = b.path("src/kernel/main.zig"),
        .target = target_k,
        .optimize = optimize,
    });
    kernel.entry = .{.symbol_name = "_start"};
    var kernel_install_step = b.addInstallArtifact(kernel, .{});

    const efi_step = b.step("efi", "Build the entry point");
    efi_step.dependOn(&efi_install_step.step);
    efi_step.dependOn(&kernel_install_step.step);

    const test_step = b.step("test", "Test if isError works");
    test_step.dependOn(&run_unit_tests.step);

    // In theory you could make a run step here that calls qemu with the generated elf file
}