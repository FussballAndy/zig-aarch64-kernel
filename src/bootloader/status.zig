const std = @import("std");
const uefi = std.os.uefi;

const log = @import("./log.zig");

const high_bit = 1 << @typeInfo(usize).Int.bits - 1;

pub fn isError(status: uefi.Status) bool {
    return @intFromEnum(status) & high_bit != 0;
}

pub fn UefiResult(E: type) type {
    return union(enum) {
        ok: E,
        err: uefi.Status,

        const Self = @This();

        pub fn printError(self: Self) void {
            if(self == .err) {
                inline for (@typeInfo(uefi.Status).Enum.fields) |field| {
                    if (self.err == @field(uefi.Status, field.name)) {
                        log.putslnErr(field.name);
                    }
                }
            }
        }
    };
}

test isError {
    try std.testing.expect(isError(uefi.Status.Unsupported));
}