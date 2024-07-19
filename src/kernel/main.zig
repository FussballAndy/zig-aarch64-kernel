
pub const Reserve = extern struct {
    name: [*:0]const u8,
    begin: usize,
    end: usize,
};

export fn _start(reserves: [*]const Reserve, reserve_size: usize) callconv(.C) void {
    _ = reserves;
    _ = reserve_size;
}