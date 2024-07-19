const std = @import("std");
const uefi = std.os.uefi;
const status = @import("./status.zig");
const sTE = status.statusToError;

const W = std.unicode.utf8ToUtf16LeStringLiteral;

const PrintError = error{InvalidUtf8,TooLongSlice};

inline fn dynamicPuts(comptime out: []const u8, stream: ?*uefi.protocol.SimpleTextOutput) uefi.Status {
    if(stream) |str| {
        return str.outputString(W(out));
    }
    return uefi.Status.Unsupported;
}

pub fn puts(comptime out: []const u8) uefi.Status {
    return dynamicPuts(out, uefi.system_table.con_out);
}

pub fn putsln(comptime out: []const u8) uefi.Status {
    return puts(out++.{'\r','\n'});
}

pub fn putsErr(comptime out: []const u8) void {
    _ = dynamicPuts(out, uefi.system_table.std_err);
}

pub fn putslnErr(comptime out: []const u8) void {
    _ = putsErr(out++.{'\r','\n'});
}