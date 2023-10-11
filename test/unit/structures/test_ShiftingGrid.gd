extends GutTest

const GridElement = preload("res://structures/GridElement.gd")
const ShiftingGrid = preload("res://structures/ShiftingGrid.gd")

var shifting_grid

func test_init_within_max():
    _set_shifting_grid(Vector2i(0, 0), Vector2i(4, 4), Rect2i(1, 1, 3, 2))
    _verify_indexes_match(Rect2i(1, 1, 3, 2))

func test_shift_right_by_one():
    _set_shifting_grid()
    _verify_indexes_match(Rect2i(0, 0, 4, 4))
    shifting_grid.move_to(Vector2i(1, 0))
    _verify_indexes_match(Rect2i(1, 0, 4, 4))

func test_shift_left_by_one():
    _set_shifting_grid()
    shifting_grid.move_to(Vector2i(-1, 0))
    _verify_indexes_match(Rect2i(-1, 0, 4, 4))
    
func test_shift_up_by_one():
    _set_shifting_grid()
    shifting_grid.move_to(Vector2i(0, -1))
    _verify_indexes_match(Rect2i(0, -1, 4, 4))

func test_shift_down_by_one():
    _set_shifting_grid()
    shifting_grid.move_to(Vector2i(0, 1))
    _verify_indexes_match(Rect2i(0, 1, 4, 4))

func test_shifting_left_in_unfilled():
    _set_shifting_grid(Vector2i(0, 0), Vector2i(4, 4), Rect2i(1, 1, 3, 3))
    _verify_indexes_match(Rect2i(1, 1, 3, 3))
    shifting_grid.move_to(Vector2i(-1, 0))
    _verify_indexes_match(Rect2i(1, 1, 2, 3))
    shifting_grid.move_to(Vector2i(3, 2))
    _verify_indexes_match(Rect2i(3, 2, 1, 2))

func test_out_of_bounds_movement():
    _set_shifting_grid(Vector2i(-4, -4), Vector2i(4, 4), Rect2i(1, 1, 3, 3))
    _verify_indexes_match(Rect2i(0, 0, 0, 0))
    shifting_grid.move_to(Vector2i(-3, -3))
    _verify_indexes_match(Rect2i(0, 0, 0, 0))
    shifting_grid.move_to(Vector2i(-2, -2))
    _verify_indexes_match(Rect2i(1, 1, 1, 1))
    shifting_grid.move_to(Vector2i(0, 0))
    _verify_indexes_match(Rect2i(1, 1, 3, 3))
    shifting_grid.move_to(Vector2i(4, -2))
    _verify_indexes_match(Rect2i(0, 0, 0, 0))
    shifting_grid.move_to(Vector2i(3, 3))
    _verify_indexes_match(Rect2i(3, 3, 1, 1))
    shifting_grid.move_to(Vector2i(2, 2))
    _verify_indexes_match(Rect2i(2, 2, 2, 2))

func test_row():
    _set_shifting_grid(Vector2i(0, 0), Vector2i(4, 4), Rect2i(-1, 0, 5, 1))
    shifting_grid.move_to(Vector2i(-1, -2))
    _verify_indexes_match(Rect2i(-1, 0, 4, 1))
    shifting_grid.move_to(Vector2i(0, -1))
    _verify_indexes_match(Rect2i(0, 0, 4, 1))
    shifting_grid.move_to(Vector2i(1, -2))
    _verify_indexes_match(Rect2i(1, 0, 3, 1))
    shifting_grid.move_to(Vector2i(2, 0))
    _verify_indexes_match(Rect2i(2, 0, 2, 1))
    shifting_grid.move_to(Vector2i(3, 0))
    _verify_indexes_match(Rect2i(3, 0, 1, 1))

func _set_shifting_grid(position = Vector2i(0, 0), buffer_dimensions=Vector2i(4, 4), max_bounds=Rect2i(-1, -1, 7, 6)):
    var create_grid_element = func(i, j):
        return GridElement.new(i, j)
    shifting_grid = ShiftingGrid.new(create_grid_element, position, buffer_dimensions, max_bounds)

func _verify_indexes_match(expected_bounds: Rect2i):
    assert_eq(shifting_grid.get_dimensions(), Vector2i(expected_bounds.size.x, expected_bounds.size.y))
    var indexes = []
    var add_element_to_indexes = func(elm, pos):
        assert_eq(elm.get_i(), pos.x)
        assert_eq(elm.get_j(), pos.y)
        indexes.append(pos)
    shifting_grid.for_each(add_element_to_indexes)
    assert_eq(indexes.size(), expected_bounds.get_area())
    var arr_i = 0
    for i in range(expected_bounds.position.x, expected_bounds.end.x):
        for j in range(expected_bounds.position.y, expected_bounds.end.y):
            assert_eq(indexes[arr_i], Vector2i(i, j))
            arr_i += 1
