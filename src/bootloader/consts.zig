// A place for various constant values, might be inlined at some point.

const std = @import("std");
const uefi = std.os.uefi;
const ProtocolAttributes = uefi.tables.OpenProtocolAttributes;
const W = std.unicode.utf8ToUtf16LeStringLiteral;


pub const KERNEL_PATH: [:0]const u16 = W("kernel");

pub const EFI_BY_HANDLE_PROTOCOL = ProtocolAttributes{.by_handle_protocol = true};
