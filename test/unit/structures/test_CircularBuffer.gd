extends GutTest

const CircularBuffer = preload("res://structures/CircularBuffer.gd")

var circular_buffer

func before_each():
	circular_buffer = CircularBuffer.new(["a", "b", "c"])

func test_single_push_to_end():
	var removed_elm = circular_buffer.push_to_end("d")
	assert_eq(removed_elm, "a")
	# verify new element appended
	assert_eq(circular_buffer.get_at(3), "d")
	# verify second element still available
	assert_eq(circular_buffer.get_at(1), "b")

func test_single_push_to_start():
	var removed_elm = circular_buffer.push_to_start("0")
	assert_eq(removed_elm, "c")
	# verify new element at beginning
	assert_eq(circular_buffer.get_at(-1), "0")
	assert_eq(circular_buffer.get_at(1), "b")

func test_multiple_push_to_end():
	for i in range(1, 7):
		circular_buffer.push_to_end(i)
	assert_eq(circular_buffer.get_at(8), 6)
	assert_eq(circular_buffer.get_at(6), 4)

func test_multiple_push_to_start():
	for i in range(1, 7):
		circular_buffer.push_to_start(i)
	assert_eq(circular_buffer.get_at(circular_buffer.get_end_i()), 4)
	assert_eq(circular_buffer.get_at(circular_buffer.get_start_i()), 6)

func test_provided_start_i():
	circular_buffer = CircularBuffer.new(["a", "b", "c"], 1)
	assert_eq(circular_buffer.get_at(2), "b")

func test_dynamic_size():
	circular_buffer = CircularBuffer.new([0, 1, 2], 0, 8)
	assert_null(circular_buffer.push_to_start(-1))
	for i in range(-1, 3):
		assert_eq(i, circular_buffer.get_at(i))
	assert_null(circular_buffer.push_to_start(-2))
	assert_null(circular_buffer.push_to_end(3))
	for i in range(-2, 4):
		assert_eq(i, circular_buffer.get_at(i))
	assert_null(circular_buffer.push_to_end(4))
	assert_null(circular_buffer.push_to_start(-3))
	for i in range(-3, 5):
		assert_eq(i, circular_buffer.get_at(i))
	assert_eq(circular_buffer.push_to_end(5), -3)
	for i in range(-2, 6):
		assert_eq(i, circular_buffer.get_at(i))
	assert_eq(circular_buffer.push_to_end(6), -2)
	for i in range(-1, 7):
		assert_eq(i, circular_buffer.get_at(i))
	assert_eq(circular_buffer.push_to_start(-2), 6)
	for i in range(-2, 6):
		assert_eq(i, circular_buffer.get_at(i))
