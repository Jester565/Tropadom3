@tool

extends Node2D

class_name ChunkManager

@export var init_chunk_position := Vector2i(-1, -1)
@export var buffer_dimensions := Vector2i(4, 4)
@export var max_bounds := Rect2i(-100, -100, 200, 200)
@export var chunk_scene: PackedScene
@export var generator_grids: Array[GeneratorGridNode] = []
@export var camera: Camera2D
var chunk_grid: ShiftingGrid
var _chunk_indexes: Vector2i
var _chunk_bounds: Rect2i
var _move_bounds: Rect2i
var _camera: Camera2D

const MOVE_BOUND_DIMENSIONS_IN_CHUNKS = Vector2i(2, 2)
const NODE_2D_VIEWPORT_CLASS_NAME = "Node2DEditorViewport"

func _ready():
	self._camera = self._get_camera()
	self._chunk_indexes = self._get_chunk_indexes_at_camera_center()
	self._chunk_bounds = Rect2i(self._chunk_indexes, buffer_dimensions)
	self._move_bounds = self._get_move_bounds(self._chunk_indexes)

	for generator_grid in generator_grids:
		generator_grid.init(self._chunk_indexes, buffer_dimensions)
	chunk_grid = ShiftingGrid.new(
		Callable(self, "_create_chunk"),
		Callable(self, "_free_chunk"),
		self._chunk_indexes,
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
	return chunk

func _free_chunk(chunk, _chunk_i, _chunk_j):
	chunk.queue_free()

func _process(_delta):
	var new_chunk_indexes = self._get_chunk_indexes_at_camera_center()
	if new_chunk_indexes != self._chunk_indexes:
		self._chunk_indexes = new_chunk_indexes
		self._chunk_bounds = Rect2i(new_chunk_indexes, buffer_dimensions)
		for generator_grid in self.generator_grids:
			generator_grid.move_to(new_chunk_indexes)
		self.chunk_grid.move_to(new_chunk_indexes)

func _get_move_bounds(chunk_indexes: Vector2i):
	return Rect2i((chunk_indexes + (buffer_dimensions - MOVE_BOUND_DIMENSIONS_IN_CHUNKS) / 2) * (Globals.CHUNK_SIZE * Globals.BLOCK_SIZE), MOVE_BOUND_DIMENSIONS_IN_CHUNKS  * (Globals.CHUNK_SIZE * Globals.BLOCK_SIZE))

func _get_chunk_indexes_at_camera_center():
	return Vector2i(round(self._camera.global_position / (Globals.CHUNK_SIZE * Globals.BLOCK_SIZE))) - buffer_dimensions / 2

func _get_camera():
	return get_parent().find_child("Camera2D")
