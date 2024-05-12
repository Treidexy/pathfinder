const pf = @import("pathfinder.zig");
const std = @import("std");

pub const mine_count = 150;

pub const GameError = error{
    MineFound,
};

pub const Game = struct {
    mines: pf.Area,

    pub fn init(safe: pf.Square, mag: usize) !Game {
        var mines = pf.SquareExt.adjacent(safe);
        mines.set(safe);

        const now = try std.time.Instant.now();
        var rng1 = std.Random.DefaultPrng.init(now.timestamp);
        var rng = rng1.random();

        for (0..mag) |_| {
            while (true) {
                const place = rng.intRangeLessThan(usize, 0, pf.size);
                if (!mines.isSet(place)) {
                    mines.set(place);
                    break;
                }
            }
        }

        return .{ .mines = mines };
    }

    pub fn getPosition(self: Game, safes: pf.Area) !pf.Position {
        var position = pf.Position.init();

        var it = safes.iterator(.{});
        while (it.next()) |i| {
            try self.mark(&position, i);
        }

        return position;
    }

    fn mark(self: Game, position: *pf.Position, square: pf.Square) !void {
        if (position.safes.isSet(square)) return;
        if (self.mines.isSet(square)) {
            return GameError.MineFound;
        }

        const adj = pf.SquareExt.adjacent(square);
        const mag = adj.intersectWith(self.mines).count();
        position.safes.set(square);
        if (mag == 0) {
            var it = adj.iterator(.{});
            while (it.next()) |i| {
                try self.mark(position, i);
            }
        } else {
            try position.tiles.put(square, mag);
        }
    }
};
