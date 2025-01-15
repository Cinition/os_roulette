const std = @import("std");
const builtin = @import("builtin");
const bullet = switch (builtin.os.tag) {
    .windows => @import("bullet/windows.zig"),
    .linux, .openbsd, .netbsd, .freebsd, .dragonfly => @import("bullet/unix.zig"),
    .macos => @import("bullet/macos.zig"),
};

pub fn main() !void {
    var prng = std.Random.DefaultPrng.init(@intCast(std.time.nanoTimestamp()));
    const random = prng.random();
    const number = random.uintAtMost(u8, 10);

    var stdout = std.io.getStdOut().writer();
    var stdin = std.io.getStdIn().reader();
    var buffer: [10]u8 = undefined;

    try stdout.print("Silly game! Guess the number between 1 and 10!\n", .{});
    try stdout.print("Input: ", .{});

    if (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |value| {
        const line = std.mem.trimRight(u8, value[0 .. value.len - 1], "\r");
        const inputNumber = try std.fmt.parseInt(u8, line, 10);

        if (inputNumber > 10) {
            try stdout.print("\nYou inputed a too high of an number!", .{});
        }

        if (number == inputNumber) {
            try stdout.print("Death!", .{});
        } else {
            try stdout.print("Survive!", .{});
        }
    }
}

test "check" {
    std.testing.expect(bullet.check());
}
