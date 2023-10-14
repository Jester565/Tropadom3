extends Element

class_name SolidElement

@export var block_type: Globals.Block

func apply(chunk: Chunk, local_chunk_bounds: Rect2i):
	self._for_each_intersection_point(local_chunk_bounds, func(chunk_pos, _element_pos, _local_pos):
		chunk.block_sources[chunk_pos.x][chunk_pos.y] = block_type
	)
