const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const args = try init.minimal.args.toSlice(init.arena.allocator());
    const stdout = std.Io.File.stdout();

    if (args.len != 2) {
        try stdout.writeStreamingAll(init.io, "Uso: MBRCHECK MBR.BIN\n");
        return;
    }

    try stdout.writeStreamingAll(init.io, "Arquivo recebido: ");
    try stdout.writeStreamingAll(init.io, args[1]);
    try stdout.writeStreamingAll(init.io, "\n");

    var arquivo = std.Io.Dir.cwd().openFile(
        init.io,
        args[1],
        .{ .mode = .read_only },
    ) catch {
        try stdout.writeStreamingAll(init.io, "Erro: nao foi possivel abrir o arquivo.\n");
        return;
    };

    defer arquivo.close(init.io);

    var buffer: [512]u8 = undefined;

    const bytes_lidos = try arquivo.readPositionalAll(
        init.io,
        &buffer,
        0,
    );

    if (bytes_lidos != 512) {
        try stdout.writeStreamingAll(init.io, "Erro: o arquivo possui menos de 512 bytes.\n");
        return;
    }

    if (buffer[510] == 0x55 and buffer[511] == 0xAA) {
        try stdout.writeStreamingAll(init.io, "MBR identificado.\n");
        try stdout.writeStreamingAll(init.io, "Endian: Little Endian\n");
    } else if (buffer[510] == 0xAA and buffer[511] == 0x55) {
        try stdout.writeStreamingAll(init.io, "MBR identificado.\n");
        try stdout.writeStreamingAll(init.io, "Endian: Big Endian\n");
    } else {
        try stdout.writeStreamingAll(init.io, "Nao e um MBR.\n");
    }
}
