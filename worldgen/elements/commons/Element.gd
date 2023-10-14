extends Node

class_name Element

@export var local_pos: Vector2i = Vector2i(0, 0)  # position of the element within the generator
@export var block_dimensions: Vector2i = Vector2i(0, 0)
var local_bounds: Rect2i :
	get:
		return Rect2i(local_pos, block_dimensions)

func apply(_chunk: Chunk, _local_chunk_bounds: Rect2i):
	assert(false, "apply not implemented")

func _for_each_intersection_point(local_chunk_bounds: Rect2i, callable: Callable):
	var intersecting_bounds = local_chunk_bounds.intersection(local_bounds)
	for i in range(intersecting_bounds.position.x, intersecting_bounds.end.x):
		for j in range(intersecting_bounds.position.y, intersecting_bounds.end.y):
			var point_local_pos = Vector2i(i, j)
			var chunk_point = point_local_pos - local_chunk_bounds.position
			var element_point = point_local_pos - self.local_pos
			callable.call(chunk_point, element_point, point_local_pos)
