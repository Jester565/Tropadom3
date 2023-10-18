@tool

extends OverlaidNode2D

class_name Generator

@export var static_elements: Array[Node2D]
@export var chunk_dimensions := Vector2i(1, 1)
@export var block_dimensions: Vector2i :
	get:
		return chunk_dimensions * Globals.CHUNK_SIZE

var _elements = []

func _ready():
	self._elements.append_array(static_elements)

func init(generator_indexes: Vector2i):
	self._pixel_bounds = Rect2i(generator_indexes * chunk_dimensions * Globals.CHUNK_SIZE * Globals.BLOCK_SIZE, chunk_dimensions * Globals.CHUNK_SIZE * Globals.BLOCK_SIZE)
	for element in static_elements:
		element.init((generator_indexes * chunk_dimensions + element.local_pos) * Globals.CHUNK_SIZE)

func generate(neighboring_generators):
	for i in 3:
		for j in 3:
			var neighbor = neighboring_generators[i][j]
			if neighbor != null:
				var relative_bounds = Rect2i(Vector2i(block_dimensions.x * (i - 1), block_dimensions.y * (j - 1)), block_dimensions)
				neighbor.get_elements_intersecting_with(relative_bounds)

func get_elements_intersecting_with(relative_bounding_rect: Rect2i):
	var elements = []
	self._for_each_intersecting_element(relative_bounding_rect, func(element):
		elements.append(element)
	)
	return elements


func apply(chunk, relative_chunk_bounds):
	self._for_each_intersecting_element(relative_chunk_bounds, func(element):
		element.apply(chunk, relative_chunk_bounds)
	)

func _for_each_intersecting_element(relative_bounds, callable: Callable):
	for element in self._elements:
		if element.local_bounds.intersects(relative_bounds):
			callable.call(element)
