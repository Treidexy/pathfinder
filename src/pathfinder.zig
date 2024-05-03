const std = @import("std");
const TileSet = std.AutoHashMap(Square, i32);
const BitSet = std.bit_set.DynamicBitSet;

pub const Board = struct {
    tiles: TileSet,
    safes: BitSet,
    flags: BitSet,
};

pub const Square = struct {
    x: i32,
    y: i32,
};
