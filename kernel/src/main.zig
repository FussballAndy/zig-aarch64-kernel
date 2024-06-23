const console = @import("console.zig");

comptime {
    asm (
        \\.globl _start
        \\_start:
        \\ldr x30, =stack_top
        \\mov sp, x30
        \\
        \\bl kmain
        \\b .
    );

}

export fn kmain() noreturn {
    console.puts("Hello world!\n");
    while (true) {}
}