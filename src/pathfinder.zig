const std = @import("std");
pub const TileMap = std.AutoHashMap(Square, usize);
pub const Area = std.bit_set.ArrayBitSet(usize, size);

pub const allocator: std.mem.Allocator = std.heap.c_allocator;
pub const width: usize = 18;
pub const height: usize = 32;
pub const size: usize = width * height;

pub const Position = struct {
    tiles: TileMap,
    safes: Area,
    flags: Area,

    pub fn init() Position {
        return .{
            .tiles = TileMap.init(allocator),
            .safes = Area.initEmpty(),
            .flags = Area.initEmpty(),
        };
    }

    pub fn clone(self: Position) !Position {
        return .{
            .tiles = try self.tiles.clone(),
            .safes = Area.initEmpty().unionWith(self.safes),
            .flags = Area.initEmpty().unionWith(self.flags),
        };
    }
};

pub const Board = struct {
    const SectorList = std.ArrayList(Sector);

    position: Position,
    sectors: SectorList,

    pub fn init(position: Position) Board {
        return .{
            .position = position,
            .sectors = SectorList.init(allocator),
        };
    }

    pub fn compute(self: *Board) !void {
        // lol what's optimization?
        self.sectors.clearAndFree();

        var it = self.position.tiles.iterator();
        while (it.next()) |tile| {
            const adj = SquareExt.adjacent(tile.key_ptr.*);
            var sector = Sector{
                .area = adj.differenceWith(self.position.safes).differenceWith(self.position.flags),
                .mag = @intCast(tile.value_ptr.*),
            };

            sector.mag -= @intCast(adj.intersectWith(self.position.flags).count());

            try self.sectors.append(sector);
        }
    }

    pub fn clarify(self: *Board) !void {
        try self.compute();

        for (self.sectors.items) |a| {
            if (a.mag == 0) {
                self.position.safes.setUnion(a.area);
                continue;
            }

            if (a.mag == a.area.count()) {
                self.position.flags.setUnion(a.area);
                continue;
            }

            for (self.sectors.items) |b| {
                if (a.mag < b.mag) continue;
                if (a.area.eql(b.area)) continue;
                if (a.area.intersectWith(b.area).count() == 0) continue;

                if (a.mag - b.mag == a.area.differenceWith(b.area).count()) {
                    self.position.flags.setUnion(a.area.differenceWith(b.area));
                    self.position.safes.setUnion(b.area.differenceWith(a.area));
                }
            }
        }
    }
};

pub const Square = usize;

pub const Sector = struct {
    area: Area,
    mag: isize,
};

pub const SquareExt = struct {
    pub fn adjacent(self: Square) Area {
        var area = Area.initEmpty();

        for ([_]isize{ -1, 0, 1 }) |dy| {
            for ([_]isize{ -1, 0, 1 }) |dx| {
                if (dx == 0 and dy == 0) continue;

                const x = @as(isize, @intCast(self % width)) + dx;
                const y = @as(isize, @intCast(self / width)) + dy;

                if (x < 0 or x >= width or y < 0 or y >= height) continue;

                area.set(@intCast(x + y * width));
            }
        }

        return area;
    }
};
