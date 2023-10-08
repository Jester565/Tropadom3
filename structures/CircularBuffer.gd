class_name CircularBuffer

var _arr := []
var _buffer_start_i := 0
var _buffer_end_i := 0
var _start_i := 0
var _end_i := 0
var _size := 0
var _max_size := 0

func _init(initial_arr, initial_i=0, max_size=null):
    self._arr = initial_arr.duplicate()
    if max_size != null:
        self._arr.resize(max_size)
    self._max_size = self._arr.size()
    self._start_i = initial_i
    self._end_i = initial_i + initial_arr.size() - 1
    self._size = initial_arr.size()
    self._buffer_end_i = initial_arr.size() - 1

func get_at(i):
    var arr_i = self._get_arr_i(i)
    return self._arr[arr_i]

func get_start_i():
    return self._start_i

func get_end_i():
    return self._end_i

func push_to_end(elm):
    var removed_elm = null
    if self._size < self._arr.size():
        self._size += 1
    else:
        removed_elm = self._arr[self._buffer_start_i]
        self._start_i += 1
        self._buffer_start_i += 1
        if self._buffer_start_i >= self._arr.size():
            self._buffer_start_i = 0
    self._end_i += 1
    self._buffer_end_i += 1
    if self._buffer_end_i >= self._arr.size():
        self._buffer_end_i = 0
    self._arr[self._buffer_end_i] = elm
    return removed_elm

func push_to_start(elm):
    var removed_elm = null
    if self._size < self._arr.size():
        self._size += 1
    else:
        removed_elm = self._arr[self._buffer_end_i]
        self._end_i -= 1
        self._buffer_end_i -= 1
        if self._buffer_end_i < 0:
            self._buffer_end_i = self._arr.size() - 1
    self._start_i -= 1
    self._buffer_start_i -= 1
    if self._buffer_start_i < 0:
        self._buffer_start_i = self._arr.size() - 1
    self._arr[self._buffer_start_i] = elm
    return removed_elm

func _get_arr_i(i):
    var unoffsetted_i = i - self._start_i
    assert(
        unoffsetted_i >= 0 and unoffsetted_i < self._size,
        "Idx out of range: %s not between %s and %s" % [i, self._start_i, self._end_i]                                    
    )
    var arr_i = self._buffer_start_i + unoffsetted_i
    if arr_i >= self._arr.size():
        arr_i -= self._arr.size()
    return arr_i
