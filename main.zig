const std = @import("std");

pub fn trimNewLine(line: []const u8) []const u8 {
    const end = std.mem.find(u8, line, "\n").? - 1;
    return line[0..end];
}
pub fn main(init: std.process.Init) !void {
    while(true) {
        const cwd = std.Io.Dir.cwd();
        const file = try cwd.openFile(
            init.io, "data.txt", .{ .mode = .read_write }
        );
        defer file.close(init.io);

        var read_buffer: [1024]u8 = undefined;
        var fr = file.reader(init.io, &read_buffer);
        var reader = &fr.interface;

        var write_buffer: [1024]u8 = undefined;
        var fw = file.writer(init.io, &write_buffer);
        var writer = &fw.interface;

        var buffer: [300]u8 = undefined;
        @memset(buffer[0..], 0);
        _ = reader.readSliceAll(buffer[0..]) catch 0;

        const num = try std.fmt.parseInt(i32, trimNewLine(&buffer), 10);
        const newNum = num + 1;

        try writer.print("{}", .{newNum});
        try writer.flush();

        std.debug.print("{}\n", .{num});
        std.debug.print("{}\n", .{newNum});

        var child = try std.process.spawn(init.io, .{
            .argv = &.{ "./commit.bat" },
            .stdin = .ignore,
            .stdout = .pipe,
            .stderr = .ignore,
        });

        _ = try child.wait(init.io);
    }
}
