extends Node

class_name GeneratorGridNode

@export var max_bounds: Rect2i
@export var buffer_dimensions: Vector2i
@export var generator_scene: PackedScene

var _generator_chunk_dimensions: Vector2i
var _generator_grid: GeneratorGrid

func init(position: Vector2i):
	self._generator_chunk_dimensions = (generator_scene.instantiate() as Generator).chunk_dimensions
	self._generator_grid = GeneratorGrid.new(
		Callable(self, "_create_generator"),
		Callable(self, "_generate"),
		position,
		buffer_dimensions,
		max_bounds
	)

func move_to(position: Vector2i):
	self._generator_grid.move_to(position)

func apply(chunk: Chunk):
	var chunk_indexes = chunk.chunk_indexes
	var generator_indexes = self._chunk_to_generator_indexes(chunk_indexes)
	if max_bounds.has_point(generator_indexes):
		var generator = self._generator_grid.get_at_indexes(generator_indexes)
		var generator_chunk_indexes = generator_indexes * generator.chunk_dimensions
		var relative_chunk_bounds = (chunk_indexes - generator_chunk_indexes) * Globals.CHUNK_SIZE
		generator.apply(chunk, Rect2i(relative_chunk_bounds, Vector2i(Globals.CHUNK_SIZE, Globals.CHUNK_SIZE)))

func _create_generator(_i, _j):
	var generator = generator_scene.instantiate()
	add_child(generator)
	return generator

func _generate(generator, neighboring_generators, _i, _j):
	generator.generate(neighboring_generators)

func _chunk_to_generator_indexes(chunk_indexes: Vector2i):
	return Vector2i(floor(Vector2(
		float(chunk_indexes.x) / self._generator_chunk_dimensions.x,
		float(chunk_indexes.y) / self._generator_chunk_dimensions.y
	)))
