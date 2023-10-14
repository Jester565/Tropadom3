class_name ShiftingGrid

const GridElement = preload("res://structures/GridElement.gd")

var _create_fn: Callable
var _grid: CircularBuffer = null
var _bounds
var _max_bounds
var _buffer_dimensions

func _init(create_fn: Callable, position: Vector2i, buffer_dimensions: Vector2i, max_bounds: Rect2i):
	self._create_fn = create_fn
	self._max_bounds = max_bounds
	self._buffer_dimensions = buffer_dimensions
	var uncontained_bounds = Rect2i(position, buffer_dimensions)
	self._bounds = max_bounds.intersection(uncontained_bounds)
	if self._bounds.has_area():
		self._init_grid(self._bounds, uncontained_bounds)

func move_to(position: Vector2i):
	var new_uncontained_bounds = Rect2i(position, self._buffer_dimensions)
	var new_bounds = self._max_bounds.intersection(new_uncontained_bounds)
	if !self._bounds.has_area() and new_bounds.has_area():
		self._init_grid(new_bounds, new_uncontained_bounds)
	elif self._bounds.has_area() and !new_bounds.has_area():
		self._clear_grid()
	elif self._bounds.has_area() and new_bounds.has_area():
		# only shift if there's some overlap
		if self._bounds.intersects(new_bounds):
			self._shift(new_bounds, new_uncontained_bounds)
		else:
			self._clear_grid()
			self._init_grid(new_bounds, new_uncontained_bounds)
	self._bounds = new_bounds

func get_at(i: int, j: int):
	return self._grid.get_at(i).get_at(j)

func get_at_indexes(indexes: Vector2i):
	return self._grid.get_at(indexes.x).get_at(indexes.y)

func get_dimensions():
	assert(
		(self._bounds.size.x == 0 and self._grid == null) or (self._bounds.size.x == self._grid.get_size()), 
		"Size of bounds and grid don't match: BoundsWidth=%s, GridSize=%s" % [self._bounds.size, self._grid.get_size() if self._grid != null else 0]
	)
	assert(
		(self._bounds.size.y == 0 and self._grid == null) or (self._bounds.size.y == self._grid.get_at(self._bounds.position.x).get_size()), 
		"Size of bounds and grid don't match: BoundsHeight=%s, ColSize=%s" % [self._bounds.size, self._grid.get_at(self._bounds.position.x).get_size() if self._grid != null else 0]
	)
	return self._bounds.size

func for_each(callable: Callable):
	if self._grid != null:
		var col_callable = func(col, i):
			var elm_callable = func(elm, j):
				callable.call(elm, Vector2i(i, j))
			col.for_each(elm_callable)
		self._grid.for_each(col_callable)

func get_bounds():
	return self._bounds

func _shift(new_bounds: Rect2i, _new_uncontained_bounds: Rect2i):
	for j in self._get_new_top_row_indexes(self._bounds, new_bounds):
		self._push_top_row(self._bounds.position.x, self._bounds.size.x)
	for j in self._get_new_bottom_row_indexes(self._bounds, new_bounds):
		self._push_bottom_row(self._bounds.position.x, self._bounds.size.x)
	
	for i in self._get_new_left_col_indexes(self._bounds, new_bounds):
		self._push_left_col(new_bounds.position.y, new_bounds.size.y)
	for i in self._get_new_right_col_indexes(self._bounds, new_bounds):
		self._push_right_col(new_bounds.position.y, new_bounds.size.y)
	
	self._remove_out_of_bounds_elements(new_bounds)
	
func _remove_out_of_bounds_elements(new_bounds):
	var col = self._grid.get_at(self._grid.get_start_i())
	var current_rect = Rect2i(self._grid.get_start_i(), col.get_start_i(), self._grid.get_size(), col.get_size())
	
	for j in range(new_bounds.size.y, current_rect.size.y):
		# top is moving down but the size is shrinking, so remove from top
		if new_bounds.position.y != current_rect.position.y:
			self._pop_top_row() 
		else:
			self._pop_bottom_row()
	for i in range(new_bounds.size.x, current_rect.size.x):
		if new_bounds.position.x != current_rect.position.x:
			self._pop_left_col()
		else:
			self._pop_right_col()

func _init_grid(bounds, _uncontained_bounds):
	self._grid = CircularBuffer.new([], bounds.position.x, self._buffer_dimensions.x)

	for i in range(bounds.position.x, bounds.end.x):
		var col = CircularBuffer.new([], bounds.position.y, self._buffer_dimensions.y)
		for j in range(bounds.position.y, bounds.end.y):
			col.push_to_end(self._create_fn.call(i, j))
		self._grid.push_to_end(col)

func _clear_grid():
	self._grid = null
	self._bounds = Rect2i(0, 0, 0, 0)

func _get_new_bottom_row_indexes(prev_bounds: Rect2i, new_bounds: Rect2i):
	return range(prev_bounds.end.y, new_bounds.end.y)

func _get_new_top_row_indexes(prev_bounds: Rect2i, new_bounds: Rect2i):
	return range(new_bounds.position.y, prev_bounds.position.y)

func _get_new_left_col_indexes(prev_bounds: Rect2i, new_bounds: Rect2i):
	return range(new_bounds.position.x, prev_bounds.position.x)

func _get_new_right_col_indexes(prev_bounds: Rect2i, new_bounds: Rect2i):
	return range(prev_bounds.end.x, new_bounds.end.x)

func _push_top_row(start_i, width):
	for i in range(start_i, start_i + width):
		var col: CircularBuffer = self._grid.get_at(i)
		col.push_to_start(self._create_fn.call(i, col.get_start_i() - 1))

func _push_bottom_row(start_i, width):
	for i in range(start_i, start_i + width):
		var col: CircularBuffer = self._grid.get_at(i)
		col.push_to_end(self._create_fn.call(i, col.get_start_i() + col.get_size()))

func _push_left_col(start_j, height):
	var col = CircularBuffer.new([], start_j, self._buffer_dimensions.y)
	for j in range(start_j, start_j + height):
		col.push_to_end(self._create_fn.call(self._grid.get_start_i() - 1, j))
	self._grid.push_to_start(col)

func _push_right_col(start_j, height):
	var col = CircularBuffer.new([], start_j, self._buffer_dimensions.y)
	for j in range(start_j, start_j + height):
		col.push_to_end(self._create_fn.call(self._grid.get_start_i() + self._grid.get_size(), j))
	self._grid.push_to_end(col)

func _pop_top_row():
	for i in range(self._grid.get_start_i(), self._grid.get_size()):
		var col: CircularBuffer = self._grid.get_at(i)
		col.pop_from_start()

func _pop_bottom_row():
	for i in range(self._grid.get_start_i(), self._grid.get_size()):
		var col: CircularBuffer = self._grid.get_at(i)
		col.pop_from_end()

func _pop_left_col():
	self._grid.pop_from_start()

func _pop_right_col():
	self._grid.pop_from_end()
