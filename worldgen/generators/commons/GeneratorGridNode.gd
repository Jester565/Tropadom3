@tool

extends Node2D

class_name GeneratorGridNode

var buffer_dimensions: Vector2i
@export var max_bounds: Rect2i
@export var generator_scene: PackedScene

var _generator_chunk_dimensions: Vector2i
var _generator_grid: GeneratorGrid

func init(chunk_indexes: Vector2i, chunk_dimensions: Vector2i):
	self._generator_chunk_dimensions = (generator_scene.instantiate() as Generator).chunk_dimensions
	var grid_indexes = _chunk_to_generator_indexes(chunk_indexes) - Vector2i(1, 1)
	var grid_dimesions = _chunk_to_generator_dimensions(chunk_dimensions) + Vector2i(2, 2)
	self._generator_grid = GeneratorGrid.new(
		Callable(self, "_create_generator"),
		Callable(self, "_generate"),
		Callable(self, "_free_generator"),
		grid_indexes,
		grid_dimesions,
		max_bounds
	)

func move_to(chunk_indexes: Vector2i):
	var grid_indexes = _chunk_to_generator_indexes(chunk_indexes) - Vector2i(1, 1)
	self._generator_grid.move_to(grid_indexes)

func apply(chunk: Chunk):
	var chunk_indexes = chunk.chunk_indexes
	var generator_indexes = self._chunk_to_generator_indexes(chunk_indexes)
	if max_bounds.has_point(generator_indexes):
		var generator = self._generator_grid.get_at_indexes(generator_indexes)
		var generator_chunk_indexes = generator_indexes * generator.chunk_dimensions
		var relative_chunk_bounds = (chunk_indexes - generator_chunk_indexes) * Globals.CHUNK_SIZE
		generator.apply(chunk, Rect2i(relative_chunk_bounds, Vector2i(Globals.CHUNK_SIZE, Globals.CHUNK_SIZE)))

func _create_generator(i, j):
	var generator = generator_scene.instantiate()
	generator.init(Vector2i(i, j))
	add_child(generator)
	return generator

func _generate(generator, neighboring_generators, _i, _j):
	generator.generate(neighboring_generators)

func _free_generator(generator, _i, _j):
	generator.queue_free()

func _chunk_to_generator_indexes(chunk_indexes: Vector2i):
	return Vector2i(floor(Vector2(
		float(chunk_indexes.x) / self._generator_chunk_dimensions.x,
		float(chunk_indexes.y) / self._generator_chunk_dimensions.y
	)))

func _chunk_to_generator_dimensions(chunk_dimensions: Vector2i):
	return Vector2i(ceil(Vector2(
		float(chunk_dimensions.x) / self._generator_chunk_dimensions.x,
		float(chunk_dimensions.y) / self._generator_chunk_dimensions.y
	)))
