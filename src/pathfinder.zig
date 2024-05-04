const std = @import("std");
pub const TileMap = std.AutoHashMap(Square, i32);
pub const Area = std.bit_set.ArrayBitSet(usize, size);

pub var allocator: std.mem.Allocator = undefined;
pub const width: usize = 18;
pub const height: usize = 32;
pub const size: usize = width * height;

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

pub const Square = usize;

pub const Sector = struct {
    area: Area,
    mag: isize,
};

pub fn adjacent(self: Square, board: Board) !Area {
    var area = Area.initEmpty();

    for (-1..1) |dy| {
        for (-1..1) |dx| {
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
