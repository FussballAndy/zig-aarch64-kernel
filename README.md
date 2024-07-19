# A simple (QEMU) AArch64 Kernel written in Zig

Sources:
- https://wiki.osdev.org/QEMU_AArch64_Virt_Bare_Bones
- https://github.com/luickk/ZigKernel
- https://github.com/krinkinmu/efi
- qemu-efi-aarch64 debian package for QEMU_EFI.fd aka. QEMU_EFI-pflash.raw (files omitted here)

Notes for windows users: you can download the debian package [here](https://packages.debian.org/bookworm/qemu-efi-aarch64) and extract the file using `llvm-ar`
or any other tool that supports it additionally git bash's mingw ships dd to create the 64MB pflash file ([more info](https://www.kraxel.org/blog/2022/05/edk2-virt-quickstart/)).

## Running

```sh
qemu-system-aarch64 -machine virt -cpu max -drive if=pflash,format=raw,file=QEMU_EFI-pflash.raw -drive format=raw,file=fat:rw:./vm/root -net none -nographic
```

## Where is efi_main or any equivalent?

Good question. The answer is: zig provides it for us in the [start.zig](https://github.com/ziglang/zig/blob/8f20e81b8816aadd8ceb1b04bd3727cc1d124464/lib/std/start.zig#L228-L248) file. I saw this earlier but still tried my own `efi_main` just to get constant compile errors as zig for what ever reason still constantly tried to inject their own.