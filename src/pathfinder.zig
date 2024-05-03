const std = @import("std");
pub const TileMap = std.AutoHashMap(Square, i32);
pub const Area = std.bit_set.ArrayBitSet(usize, size);

pub var allocator: std.mem.Allocator = undefined;
pub const width: i32 = 18;
pub const height: i32 = 32;
pub const size = width * height;

pub const Board = struct {
    tiles: TileMap,
    safes: Area,
    flags: Area,

    pub fn init() Board {
        allocator = std.heap.c_allocator;

        return .{
            .tiles = TileMap.init(allocator),
            .safes = Area.initEmpty(),
            .flags = Area.initEmpty(),
        };
    }
};

pub const Square = i32;

pub const Sector = struct {
    area: Area,
    mag: i32,
};

pub fn adjacent(self: Square, board: Board) !Area {
    var area = Area.initEmpty();

    for (-1..2) |dy| {
        for (-1..2) |dx| {
            const x = self % board.width + dx;
            const y = self / board.width + dy;

            if (x < 0 or x >= board.width or y < 0 or y >= board.height) {
                continue;
            }

            area.set(x + y * board.width);
        }
    }

    return area;
}
