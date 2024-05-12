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

    .engine_flag = [_]rl.Color{
        rl.Color.init(255, 0, 0, 128),
    },
    .engine_safe = [_]rl.Color{
        rl.Color.init(0, 0, 255, 128),
    },

    .flag = rl.Color.init(242, 54, 7, 255),
};

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Hello, world!", .{});
    defer stdout.print("Goodbye, world!", .{}) catch {};

    var position = pf.Position.init();

    var board = pf.Board.init(position);

    rl.initWindow(thicc * pf.width, thicc * pf.height, "Heigh Heogh!");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        const mx = @as(usize, @intCast(rl.getMouseX())) / thicc;
        const my = @as(usize, @intCast(rl.getMouseY())) / thicc;
        const mouse = mx + my * width;

        if (rl.isKeyPressed(rl.KeyboardKey.key_tab)) {
            try board.clarify();
        }

        if (rl.isMouseButtonPressed(rl.MouseButton.mouse_button_left)) {
            if (rl.isKeyDown(rl.KeyboardKey.key_left_control)) {
                if (!position.safes.isSet(mouse))
                    position.flags.toggle(mouse);
            } else {
                if (!position.flags.isSet(mouse)) {
                    position.safes.toggle(mouse);

                    if (rl.isKeyDown(rl.KeyboardKey.key_one)) {
                        try position.tiles.put(mouse, 1);
                        position.safes.set(mouse);
                    } else if (rl.isKeyDown(rl.KeyboardKey.key_two)) {
                        try position.tiles.put(mouse, 2);
                        position.safes.set(mouse);
                    } else if (rl.isKeyDown(rl.KeyboardKey.key_three)) {
                        try position.tiles.put(mouse, 3);
                        position.safes.set(mouse);
                    } else if (rl.isKeyDown(rl.KeyboardKey.key_four)) {
                        try position.tiles.put(mouse, 4);
                        position.safes.set(mouse);
                    } else if (rl.isKeyDown(rl.KeyboardKey.key_five)) {
                        try position.tiles.put(mouse, 5);
                        position.safes.set(mouse);
                    } else if (rl.isKeyDown(rl.KeyboardKey.key_six)) {
                        try position.tiles.put(mouse, 6);
                        position.safes.set(mouse);
                    } else if (rl.isKeyDown(rl.KeyboardKey.key_seven)) {
                        try position.tiles.put(mouse, 7);
                        position.safes.set(mouse);
                    } else if (rl.isKeyDown(rl.KeyboardKey.key_eight)) {
                        try position.tiles.put(mouse, 8);
                        position.safes.set(mouse);
                    } else {
                        _ = position.tiles.remove(mouse);
                    }
                }
            }

            board = pf.Board.init(position);
        }

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.init(64, 64, 64, 255));

        drawArea(pf.Area.initFull(), Colors.unknown.len, Colors.unknown, 0);
        drawArea(position.safes, Colors.safe.len, Colors.safe, 0);
        drawArea(position.flags, 1, .{Colors.flag}, 8);

        var it = position.tiles.iterator();
        while (it.next()) |entry| {
            const x = entry.key_ptr.* % width;
            const y = entry.key_ptr.* / width;

            rl.drawText(&[2:0]u8{ @as(u8, @intCast(entry.value_ptr.*)) + '0', 0 }, @intCast(x * thicc + 3), @intCast(y * thicc + 2), 28, rl.Color.black);
        }

        drawArea(board.position.safes.differenceWith(position.safes), Colors.engine_safe.len, Colors.engine_safe, 0);
        drawArea(board.position.flags.differenceWith(position.flags), Colors.engine_flag.len, Colors.engine_flag, 0);
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
