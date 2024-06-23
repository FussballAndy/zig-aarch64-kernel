const std = @import("std");
const fmt = std.fmt;
const Writer = std.io.Writer;

var buffer = @as([*]volatile u16, @ptrFromInt(0x09000000));

pub fn puts(data: []const u8) void {
    for (data) |c|
        buffer[0] = c;
}

pub const writer = Writer(void, error{}, callback){ .context = {} };

fn callback(_: void, string: []const u8) error{}!usize {
    puts(string);
    return string.len;
}

pub fn printf(comptime format: []const u8, args: anytype) void {
    fmt.format(writer, format, args) catch unreachable;
}