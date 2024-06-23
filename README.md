# A simple (QEMU) AArch64 Kernel written in Zig

Sources:
- https://wiki.osdev.org/QEMU_AArch64_Virt_Bare_Bones
- https://github.com/luickk/ZigKernel

## Future notes
- Change the entry back to a naked function once zig fixes those up as right now
you cannot call inside of a naked function. [#18183](https://github.com/ziglang/zig/issues/18183)