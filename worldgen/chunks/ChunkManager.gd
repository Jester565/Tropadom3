extends Node2D

class_name ChunkManager

@export var init_chunk_position := Vector2i(-2, -2)
@export var buffer_dimensions := Vector2i(6, 6)
@export var max_bounds := Rect2i(-100, -100, 200, 200)
@export var chunk_scene: PackedScene
@export var generator_grids: Array[GeneratorGridNode] = []
var chunk_grid: ShiftingGrid

func _ready():
	for generator_grid in generator_grids:
		generator_grid.init(init_chunk_position)
	chunk_grid = ShiftingGrid.new(
		Callable(self, "_create_chunk"),
		init_chunk_position,
		buffer_dimensions,
		max_bounds
	)

func _create_chunk(chunk_i, chunk_j):
	var chunk = chunk_scene.instantiate()
	var chunk_indexes = Vector2i(chunk_i, chunk_j)
	chunk.chunk_indexes = chunk_indexes
	chunk.position = chunk_indexes * Globals.CHUNK_SIZE * Globals.BLOCK_SIZE
	for generator_grid in generator_grids:
		generator_grid.apply(chunk)
	chunk.write_block_sources()
	add_child(chunk)
