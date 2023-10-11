extends GutTest

const Generator = preload("res://worldgen/generators/commons/Generator.gd")
const GeneratorGrid = preload("res://worldgen/generators/commons/GeneratorGrid.gd")

var DoubleGenerator
var generator_grid: GeneratorGrid

func before_each():
    stub(Generator, 'generate').to_do_nothing()
    DoubleGenerator = double(Generator)

func test_init():
    _set_generator_grid()
    _verify_generate_only_called_in_bounds(Rect2i(1, 1, 2, 2))
    # check neighbor args
    var generator = generator_grid.get_at(2, 2)
    var neighbors = get_call_parameters(generator, 'generate')[0]
    for i in 3:
        for j in 3:
            assert_eq(neighbors[i][j], generator_grid.get_at(i + 1, j + 1))

func test_shift_right_by_one():
    _set_generator_grid()
    generator_grid.move_to(Vector2i(1, 0))
    _verify_generate_only_called_in_bounds(Rect2i(1, 1, 3, 2))
    # check neighbor args
    var generator = generator_grid.get_at(3, 2)
    var neighbors = get_call_parameters(generator, 'generate')[0]
    for i in 3:
        for j in 3:
            assert_eq(neighbors[i][j], generator_grid.get_at(i + 2, j + 1))

func test_shift_left_by_one():
    _set_generator_grid()
    generator_grid.move_to(Vector2i(-1, 0))
    _verify_generate_only_called_in_bounds(Rect2i(0, 1, 3, 2))
    # check neighbor args
    var generator = generator_grid.get_at(0, 2)
    var neighbors = get_call_parameters(generator, 'generate')[0]
    for i in 3:
        for j in 3:
            assert_eq(neighbors[i][j], generator_grid.get_at(i - 1, j + 1))

func test_shift_down_by_one():
    _set_generator_grid()
    generator_grid.move_to(Vector2i(0, 1))
    _verify_generate_only_called_in_bounds(Rect2i(1, 1, 2, 3))
    # check neighbor args
    var generator = generator_grid.get_at(2, 3)
    var neighbors = get_call_parameters(generator, 'generate')[0]
    for i in 3:
        for j in 3:
            assert_eq(neighbors[i][j], generator_grid.get_at(i + 1, j + 2))

func test_shift_up_by_one():
    _set_generator_grid()
    generator_grid.move_to(Vector2i(0, -1))
    _verify_generate_only_called_in_bounds(Rect2i(1, 0, 2, 3))
    # check neighbor args
    var generator = generator_grid.get_at(2, 0)
    var neighbors = get_call_parameters(generator, 'generate')[0]
    for i in 3:
        for j in 3:
            assert_eq(neighbors[i][j], generator_grid.get_at(i + 1, j - 1))

func test_row():
    _set_generator_grid(Vector2i(0, 0), Vector2i(4, 4), Rect2i(-1, 0, 4, 1), 1, 0)
    generator_grid.move_to(Vector2i(-2, -1))
    _verify_generate_only_called_in_bounds(Rect2i(-1, 0, 4, 1))

func test_out_of_bounds_movement():
    _set_generator_grid(Vector2i(-4, -4), Vector2i(4, 4), Rect2i(1, 1, 3, 3))
    generator_grid.move_to(Vector2i(-3, -3))
    generator_grid.move_to(Vector2i(-2, -2))
    generator_grid.move_to(Vector2i(0, 0))
    generator_grid.move_to(Vector2i(4, -2))
    generator_grid.move_to(Vector2i(3, 3))
    generator_grid.move_to(Vector2i(2, 2))
    for i in range(2, 3):
        for j in range(2, 3):
            var generator = generator_grid.get_at(i, j)
            assert_not_called(generator, 'generate')

func _set_generator_grid(pos=Vector2i(0, 0), buf_dims=Vector2i(4, 4), max_bounds=Rect2i(-2, -2, 9, 9), dist_x_sides=1, dist_y_sides=1):
    var create_generator = func(i, j):
        return DoubleGenerator.new(i, j)
    var generate = func(generator, neighboring_generators, _i, _j):
        return generator.generate(neighboring_generators)
    generator_grid = GeneratorGrid.new(create_generator, generate, pos, buf_dims, max_bounds, dist_x_sides, dist_y_sides)

func _verify_generate_only_called_in_bounds(generate_bounds: Rect2i):
    var check_generate_call = func(generator, pos):
        if generate_bounds.has_point(pos):
            assert_call_count(generator, 'generate', 1)
        else:
            assert_not_called(generator, 'generate')
    generator_grid.for_each(check_generate_call)
