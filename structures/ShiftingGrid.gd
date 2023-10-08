class_name ShiftingGrid

const GridElement = preload("res://structures/GridElement.gd")

var _GridElement
var _grid: CircularBuffer
var _idx_rect: Rect2i
var _buffer_width = 0
var _buffer_height = 0
var _max_idx_rect: Rect2i

func _init(GridElementClass, init_idx_rect: Rect2i, max_idx_rect: Rect2i):
    self._GridElement = GridElementClass
    self._max_idx_rect = max_idx_rect
    self._buffer_width = init_idx_rect.size.x + 1
    self._buffer_height = init_idx_rect.size.y + 1
    var contained_idx_rect = max_idx_rect.intersection(init_idx_rect)
    self._idx_rect = contained_idx_rect
    self._grid = CircularBuffer.new([], contained_idx_rect.position.x, self._buffer_width)
    
    for i in range(contained_idx_rect.position.x, contained_idx_rect.end.x + 1):
        var col = CircularBuffer.new([], contained_idx_rect.position.y, self._buffer_height)
        for j in range(contained_idx_rect.position.y, contained_idx_rect.end.y + 1):
            col.push_to_end(GridElement.new(i, j))
        self._grid.push_to_end(col)

func shift(new_idx_rect: Rect2i):
    var new_contained_idx_rect = self._max_idx_rect.intersection(new_idx_rect)
    for j in range(self._idx_rect.end.y + 1, new_contained_idx_rect.end.y + 1):
        for i in range(self._idx_rect.position.x, self._idx_rect.end.x + 1):
            var col: CircularBuffer = self._grid.get_at(i)
            col.push_to_end(self._GridElement.new(i, j))
    for j in range(new_contained_idx_rect.position.y, self._idx_rect.position.y):
        for i in range(self._idx_rect.position.x, self._idx_rect.end.x + 1):
            var col: CircularBuffer = self._grid.get_at(i)
            col.push_to_start(self._GridElement.new(i, j))
    for i in range(self._idx_rect.end.x + 1, new_contained_idx_rect.end.x + 1):
        var col = CircularBuffer.new([], new_contained_idx_rect.position.y, self._buffer_height)
        for j in range(new_contained_idx_rect.position.y, new_contained_idx_rect.end.y + 1):
            col.push_to_end(self._GridElement.new(i, j))
        self._grid.push_to_end(col)
    for i in range(new_contained_idx_rect.position.x, self._idx_rect.position.x):
        var col = CircularBuffer.new([], new_contained_idx_rect.position.y, self._buffer_height)
        for j in range(new_contained_idx_rect.position.y, new_contained_idx_rect.end.y + 1):
            col.push_to_end(self._GridElement.new(i, j))
        self._grid.push_to_start(col)

func get_at(i: int, j: int) -> GridElement:
    return self._grid.get_at(i).get_at(j)