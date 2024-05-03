const std = @import("std");
const rl = @import("raylib");
const pf = @import("pathfinder.zig");

const width = pf.width;
const height = pf.height;
const size = pf.size;
const thicc = 30;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Hello, world!", .{});
    defer stdout.print("Goodbye, world!", .{}) catch {};

    _ = pf.Board.init();

    rl.initWindow(thicc * pf.width, thicc * pf.height, "Heigh Heogh!");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.init(64, 64, 64, 255));

        for (0..size) |i| {
            const x: i32 = @as(i32, @intCast(i)) % width;
            const y: i32 = @as(i32, @intCast(i)) / width;

            rl.drawRectangle(x * thicc, y * thicc, thicc, thicc, rl.Color.green);
        }
    }
}
