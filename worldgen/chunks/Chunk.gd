@tool

extends OverlaidNode2D

class_name Chunk

@export var tile_map: TileMap
@export var chunk_indexes: Vector2i :
	set(new_indexes):
		self._pixel_bounds = Rect2i(chunk_indexes * (Globals.CHUNK_SIZE * Globals.BLOCK_SIZE), Vector2i(Globals.CHUNK_SIZE, Globals.CHUNK_SIZE) * Globals.BLOCK_SIZE)
		chunk_indexes = new_indexes

@export var block_indexes: Vector2i :
	get:
		return chunk_indexes * Globals.CHUNK_SIZE
@export var block_bounds: Rect2i :
	get:
		return Rect2i(block_indexes, Vector2i(Globals.CHUNK_SIZE, Globals.CHUNK_SIZE))

const BLOCK_LAYER := 0
const BLOCK_SOURCE_ID := 1
var block_sources = []

func _init():
	self._set_empty_block_sources()

func write_block_sources():
	for i in Globals.CHUNK_SIZE:
		for j in Globals.CHUNK_SIZE:
			var block_id = self.block_sources[i][j]
			if block_id != Globals.Block.AIR:
				var block_source_locators = Globals.BLOCKS_TO_ATLAS_CORDS[block_id]
				var source_id = block_source_locators[0]
				var atlas_cords = block_source_locators[1]
				tile_map.set_cell(
					BLOCK_LAYER,
					Vector2i(i, j),
					source_id,
					atlas_cords
				)

func _set_empty_block_sources():
	for i in Globals.CHUNK_SIZE:
		var col = []
		for j in Globals.CHUNK_SIZE:
			col.append(Globals.Block.AIR)
		block_sources.append(col)
