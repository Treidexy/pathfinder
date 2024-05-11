const std = @import("std");
pub const TileMap = std.AutoHashMap(Square, i32);
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

    pub fn clone(self: Position) Position {
        return .{
            .tiles = self.tiles.clone(),
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

    pub fn compute(self: Board) void {
        // lol what's optimization?
        self.sectors.clearAndFree();

        var it = self.position.tiles.iterator();
        while (it.next()) |tile| {
            var sector = .{
                .area = SquareExt.adjacent(tile.key_ptr, self.position).differenceWith(self.position.safes).differenceWith(self.position.flags),
                .mag = tile.value_ptr.*,
            };

            sector.mag -= sector.area.unionWith(self.position.flags);

            self.sectors.append(sector);
        }
    }

    pub fn clarify(self: Board) void {
        self.compute();

        for (self.sectors) |a| {
            for (self.sectors) |b| {
                if (a == b) {
                    continue;
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
    pub fn adjacent(self: Square, position: Position) Area {
        var area = Area.initEmpty();

        for (-1..1) |dy| {
            for (-1..1) |dx| {
                if (dx == 0 and dy == 0) {
                    continue;
                }

                const x = self % position.width + dx;
                const y = self / position.width + dy;

                if (x < 0 or x >= position.width or y < 0 or y >= position.height) {
                    continue;
                }

                area.set(x + y * position.width);
            }
        }

        return area;
    }
};
