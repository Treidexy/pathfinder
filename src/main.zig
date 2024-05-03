const std = @import("std");
const rl = @import("raylib");
const pathfinder = @import("pathfinder.zig");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Hello, world!", .{});
    defer stdout.print("Goodbye, world!", .{});

    rl.initWindow(640, 480, "Heigh Heogh!");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.white);
        rl.drawText("Congrats! You created your first window!", 190, 200, 20, rl.Color.light_gray);
    }
}
