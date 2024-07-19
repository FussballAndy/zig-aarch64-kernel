// fs is not really a fitting name, however this part is supposed to interact with the disk so whatever /shrug/

const std = @import("std");
const uefi = std.os.uefi;
const Status = uefi.Status;
const EfiError = Status.EfiError;

const log = @import("./log.zig");
const statusTools = @import("./status.zig");
const Result = statusTools.UefiResult(*uefi.protocol.File);

const constants = @import("./consts.zig");
const EFI_BY_HANDLE_PROTOCOL = constants.EFI_BY_HANDLE_PROTOCOL;

pub fn getRootDir(boot: *uefi.tables.BootServices) Result {
    var guid align(8) = uefi.protocol.LoadedImage.guid;
    var image: ?*uefi.protocol.LoadedImage = null;
    var status = boot.openProtocol(uefi.handle, &guid, @ptrCast(&image), uefi.handle, null, EFI_BY_HANDLE_PROTOCOL);
    if(status != .Success) {
        log.putslnErr("Failed to open loaded image protocol!");
        return Result{.err = status};
    }
    
    if(image == null) {
        log.putslnErr("Image somehow is null.");
        return Result{.err = Status.Aborted};
    }

    const root_device = image.?.device_handle orelse return Result{.err = Status.Aborted};

    var rootfs_raw: ?*uefi.protocol.SimpleFileSystem = null;
    guid = uefi.protocol.SimpleFileSystem.guid;
    status = boot.openProtocol(root_device, &guid, @ptrCast(&rootfs_raw), uefi.handle, null, EFI_BY_HANDLE_PROTOCOL);
    if(status != .Success) {
        log.putslnErr("Failed to get root volume");
        return Result{.err = status};
    }

    var rootfs = rootfs_raw orelse return Result{.err = Status.Aborted};
    var rootdir: *uefi.protocol.File = undefined;

    status = rootfs.openVolume(&rootdir);
    if(status != .Success) {
        log.putslnErr("Failed to open volume.");
        return Result{.err = status};
    }
    
    return Result{.ok = rootdir};
}