extends GutTest

const GridElement = preload("res://structures/GridElement.gd")
const ShiftingGrid = preload("res://structures/ShiftingGrid.gd")

var shifting_grid: ShiftingGrid

func before_each():
    shifting_grid = ShiftingGrid.new(GridElement, Rect2i(0, 0, 3, 3), Rect2i(-1, -1, 6, 5))

func test_init_within_max():
    shifting_grid = ShiftingGrid.new(GridElement, Rect2i(0, 0, 3, 3), Rect2i(1, 1, 2, 1))
    var top_left_elm = shifting_grid.get_at(1, 1)
    assert_eq(top_left_elm.get_i(), 1)
    assert_eq(top_left_elm.get_j(), 1)

    var bottom_right_elm = shifting_grid.get_at(3, 2)
    assert_eq(bottom_right_elm.get_i(), 3)
    assert_eq(bottom_right_elm.get_j(), 2)

func test_shift_right_by_one():
    shifting_grid.shift(Rect2i(1, 0, 3, 3))
    var bottom_right_elm = shifting_grid.get_at(4, 3)
    assert_eq(bottom_right_elm.get_i(), 4)
    assert_eq(bottom_right_elm.get_j(), 3)

func test_shift_left_by_one():
    shifting_grid.shift(Rect2i(-1, 0, 3, 3))
    var left_elm = shifting_grid.get_at(-1, 2)
    assert_eq(left_elm.get_i(), -1)
    assert_eq(left_elm.get_j(), 2)
    
func test_shift_up_by_one():
    shifting_grid.shift(Rect2i(0, -1, 3, 3))
    var top_right_elm = shifting_grid.get_at(3, -1)
    assert_eq(top_right_elm.get_i(), 3)
    assert_eq(top_right_elm.get_j(), -1)

func test_shift_down_by_one():
    shifting_grid.shift(Rect2i(0, 1, 3, 3))
    var bottom_left_elm = shifting_grid.get_at(0, 4)
    assert_eq(bottom_left_elm.get_i(), 0)
    assert_eq(bottom_left_elm.get_j(), 4)

func test_shifting_left_in_unfilled():
    shifting_grid = ShiftingGrid.new(GridElement, Rect2i(0, 0, 3, 3), Rect2i(1, 1, 2, 2))
    shifting_grid.shift(Rect2i(-1, 0, 3, 3))
    var bottom_right_elm = shifting_grid.get_at(3, 3)
    assert_eq(bottom_right_elm.get_i(), 3)
    assert_eq(bottom_right_elm.get_j(), 3)
    shifting_grid.shift(Rect2i(2, 0, 3, 3))
    var bottom_left_elm = shifting_grid.get_at(2, 3)
    assert_eq(bottom_left_elm.get_i(), 2)
    assert_eq(bottom_left_elm.get_j(), 3)

func test_row():
    shifting_grid = ShiftingGrid.new(GridElement, Rect2i(0, 0, 3, 3), Rect2i(-1, 0, 4, 1))
    shifting_grid.shift(Rect2i(-1, -2, 3, 3))
    var elm = shifting_grid.get_at(-1, 0)
    assert_eq(elm.get_i(), -1)
    assert_eq(elm.get_j(), 0)
    shifting_grid.get_at(2, 1)
