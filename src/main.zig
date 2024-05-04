const std = @import("std");
const rl = @import("raylib");
const pf = @import("pathfinder.zig");

const width = pf.width;
const height = pf.height;
const size = pf.size;
const thicc: @TypeOf(size) = 30;

const Colors = .{
    .unknown = [_]rl.Color{
        rl.Color.init(162, 209, 73, 255),
        rl.Color.init(170, 215, 81, 255),
    },

    .safe = [_]rl.Color{
        rl.Color.init(229, 194, 159, 255),
        rl.Color.init(215, 184, 153, 255),
    },

    .flag = rl.Color.init(242, 54, 7, 255),
};

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Hello, world!", .{});
    defer stdout.print("Goodbye, world!", .{}) catch {};

    var board = pf.Board.init();

    rl.initWindow(thicc * pf.width, thicc * pf.height, "Heigh Heogh!");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        const mx = @as(usize, @intCast(rl.getMouseX())) / thicc;
        const my = @as(usize, @intCast(rl.getMouseY())) / thicc;
        const mouse = mx + my * width;

        if (rl.isMouseButtonPressed(rl.MouseButton.mouse_button_left)) {
            if (rl.isKeyDown(rl.KeyboardKey.key_left_control)) {
                if (!board.safes.isSet(mouse))
                    board.flags.toggle(mouse);
            } else {
                if (!board.flags.isSet(mouse)) {
                    if (!board.safes.isSet(mouse)) {
                        if (rl.isKeyDown(rl.KeyboardKey.key_one)) {
                            try board.tiles.put(mouse, 1);
                        } else if (rl.isKeyDown(rl.KeyboardKey.key_two)) {
                            try board.tiles.put(mouse, 2);
                        } else if (rl.isKeyDown(rl.KeyboardKey.key_three)) {
                            try board.tiles.put(mouse, 3);
                        } else if (rl.isKeyDown(rl.KeyboardKey.key_four)) {
                            try board.tiles.put(mouse, 4);
                        } else if (rl.isKeyDown(rl.KeyboardKey.key_five)) {
                            try board.tiles.put(mouse, 5);
                        } else if (rl.isKeyDown(rl.KeyboardKey.key_six)) {
                            try board.tiles.put(mouse, 6);
                        } else if (rl.isKeyDown(rl.KeyboardKey.key_seven)) {
                            try board.tiles.put(mouse, 7);
                        } else if (rl.isKeyDown(rl.KeyboardKey.key_eight)) {
                            try board.tiles.put(mouse, 8);
                        }

                        board.safes.set(mouse);
                    } else {
                        _ = board.tiles.remove(mouse);
                        board.safes.unset(mouse);
                    }
                }
            }
        }

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.init(64, 64, 64, 255));

        drawArea(pf.Area.initFull(), Colors.unknown.len, Colors.unknown, 0);
        drawArea(board.safes, Colors.safe.len, Colors.safe, 0);
        drawArea(board.flags, 1, .{Colors.flag}, 8);

        var it = board.tiles.iterator();
        while (it.next()) |entry| {
            const x = entry.key_ptr.* % width;
            const y = entry.key_ptr.* / width;

            rl.drawText(&[2:0]u8{ @as(u8, @intCast(entry.value_ptr.*)) + '0', 0 }, @intCast(x * thicc + 3), @intCast(y * thicc + 2), 28, rl.Color.black);
        }
    }
}

fn drawArea(area: pf.Area, comptime len: usize, colors: [len]rl.Color, padding: usize) void {
    var it = area.iterator(.{});
    while (it.next()) |i| {
        const x = i % width;
        const y = i / width;
        const mod = (x + y) % colors.len;

        rl.drawRectangle(@intCast(x * thicc + padding), @intCast(y * thicc + padding), @intCast(thicc - 2 * padding), @intCast(thicc - 2 * padding), colors[mod]);
    }
}
