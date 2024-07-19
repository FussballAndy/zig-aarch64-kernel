const std = @import("std");
const uefi = std.os.uefi;

const Status = uefi.Status;
const EfiError = Status.EfiError;

const loaderMod = @import("./loader.zig");
const KernelData = loaderMod.KernelData;

const log = @import("./log.zig");

const EntryType = *const fn([*]const loaderMod.Reserve, usize) callconv(.C) void;

fn exitBootServices(boot: *uefi.tables.BootServices) Status {
    var mmap: ?[*]uefi.tables.MemoryDescriptor = null;
    var mmap_size: usize = 4096;
    var mmap_key: usize = 0;
    var desc_size: usize = 0;
    var desc_version: u32 = 0;

    while(true) {
        var status = boot.allocatePool(uefi.tables.MemoryType.LoaderData, mmap_size, @ptrCast(&mmap));
        if(status != .Success) {
            log.putslnErr("Failed to allocate a pool for memory map data.");
            return status;
        }

        status = boot.getMemoryMap(&mmap_size, mmap, &mmap_key, &desc_size, &desc_version);
        if(status == .Success) break;

        _ = boot.freePool(@ptrCast(mmap));

        if(status == .BufferTooSmall) {
            mmap_size *= 2;
            continue;
        }
        return status;
    }

    const status = boot.exitBootServices(uefi.handle, mmap_key);
    if(status != .Success) {
        _ = boot.freePool(@ptrCast(mmap));
    }

    return status;
}

pub fn startKernel(boot: *uefi.tables.BootServices, data: *KernelData) Status {
    const reserves = data.reserves.toOwnedSlice() catch return Status.Aborted;
    const status = exitBootServices(boot);
    if(status != .Success) {
        return status;
    }

    const entry: EntryType = @ptrFromInt(data.kernel_image_entry);
    entry(reserves.ptr, reserves.len);

    while (true) {}
    return EfiError.LoadError;
}