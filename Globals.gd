extends Node

var BLOCK_SIZE = 32
var CHUNK_SIZE = 64

enum Block { 
    AIR = -1,
    WOOD_PLANK = 0,
    SAND = 1,
    SANDSTONE = 2,
    WATER = 3,
    FURNACE = 4,
    LIT_FURNACE = 5,
    COBBLESTONE = 6,
    COAL = 7
}

const BLOCKS_TO_ATLAS_CORDS = [
    [1, Vector2i(0, 0)], # wood plank
    [1, Vector2i(1, 0)], # sand
    [1, Vector2i(2, 0)], # sandstone
    [1, Vector2i(0, 1)], # water
    [1, Vector2i(1, 1)], # furnace
    [1, Vector2i(2, 1)], # lit furnace
    [1, Vector2i(0, 2)], # cobblestone
    [1, Vector2i(1, 2)], # coal
]
