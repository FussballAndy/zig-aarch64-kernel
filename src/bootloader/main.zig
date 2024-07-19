const std = @import("std");
const uefi = std.os.uefi;
const log = @import("./log.zig");
const statusTools = @import("./status.zig");
const sTE = statusTools.statusToError;
const isError = statusTools.isError;
const loader = @import("./loader.zig");

const fs = @import("./fs.zig");

const exec = @import("./executor.zig");

pub fn main() uefi.Status {
    const status = log.putsln("Loading file handles.");
    if(status != .Success) {
        return status;
    }

    defer _ = log.putsln("\r\n"); // Padding

    const boot = uefi.system_table.boot_services orelse {
        log.putslnErr("Failed to load boot services");
        return uefi.Status.Unsupported;
    };

    const rootdir_result = fs.getRootDir(boot);
    if(rootdir_result == .err) {
        rootdir_result.printError();
        return rootdir_result.err;
    }
    const rootdir = rootdir_result.ok;


    _ = log.putsln("Success.");
    _ = log.putsln("Loading kernel into memory.");

    const kernel_data_raw = loader.loadKernel(boot, rootdir);
    if(kernel_data_raw == .err) {
        kernel_data_raw.printError();
        return kernel_data_raw.err;
    }
    var kernel_data = kernel_data_raw.ok;

    _ = log.putsln("Success.");

    _ = log.putsln("Starting kernel. Have fun");
    return exec.startKernel(boot, &kernel_data);
}
