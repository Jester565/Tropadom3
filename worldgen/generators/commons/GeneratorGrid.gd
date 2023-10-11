extends ShiftingGrid

var _generate_fn: Callable
var _generate_bounds: Rect2i
var _generate_at_distance_from_x_sides
var _generate_at_distance_from_y_sides

func _init(create_fn: Callable, generate_fn: Callable, position: Vector2i, buffer_dimensions: Vector2i, max_bounds: Rect2i, generate_at_distance_from_x_sides=1, generate_at_distance_from_y_sides=1):
    self._generate_fn = generate_fn
    self._generate_at_distance_from_x_sides = generate_at_distance_from_x_sides
    self._generate_at_distance_from_y_sides = generate_at_distance_from_y_sides
    super(create_fn, position, buffer_dimensions, max_bounds)
    
func _init_grid(bounds, uncontained_bounds):
    super(bounds, uncontained_bounds)
    self._run_generate_on_bounds(uncontained_bounds)

func _run_generate_on_bounds(uncontained_bounds):
    var generate_bounds = self._get_generate_bounds(uncontained_bounds)
    self._generate_bounds = generate_bounds
    for j in range(generate_bounds.position.y, generate_bounds.end.y):
        self._generate_row(j, generate_bounds.position.x, generate_bounds.end.x)

func _shift(new_bounds, new_uncontained_bounds):
    super(new_bounds, new_uncontained_bounds)
    var new_generate_bounds = self._get_generate_bounds(new_uncontained_bounds)
    if new_generate_bounds.has_area():
        if !self._generate_bounds.has_area():
            self._run_generate_on_bounds(new_uncontained_bounds)
        else:
            for j in self._get_new_top_row_indexes(self._generate_bounds,new_generate_bounds):
                self._generate_row(j, new_generate_bounds.position.x,new_generate_bounds.end.x)
            for j in self._get_new_bottom_row_indexes(self._generate_bounds, new_generate_bounds):
                self._generate_row(j, new_generate_bounds.position.x, new_generate_bounds.end.x)
            for i in self._get_new_left_col_indexes(self._generate_bounds, new_generate_bounds):
                self._generate_col(i, new_generate_bounds.position.y, new_generate_bounds.end.y)
            for i in self._get_new_right_col_indexes(self._generate_bounds, new_generate_bounds):
                self._generate_col(i, new_generate_bounds.position.y,new_generate_bounds.end.y)
    self._generate_bounds = new_generate_bounds

func _clear_grid():
    self._generate_bounds = Rect2i(0, 0, 0, 0)

func _generate_row(j, start_i, end_i):
    var neighboring_generators = self._get_neighboring_generators(start_i, j)
    for i in range(start_i, end_i):
        var generator = neighboring_generators[1][1]
        self._generate_fn.call(generator, neighboring_generators, i, j)
        if i + 1 < end_i:
            self._shift_neighboring_generators_right(neighboring_generators, i + 1, j)

func _generate_col(i, start_j, end_j):
    var neighboring_generators = self._get_neighboring_generators(i, start_j)
    for j in range(start_j, end_j):
        var generator = neighboring_generators[1][1]
        self._generate_fn.call(generator, neighboring_generators, i, j)
        if j + 1 < end_j:
            self._shift_neighboring_generators_down(neighboring_generators, i, j + 1)

func _get_neighboring_generators(i, j):
    var neighboring_generators = [
        [null, null, null],
        [null, null, null],
        [null, null, null],
    ]
    var neighbor_rect = Rect2i(i - 1, j - 1, 3, 3)
    var contained_neighbor_rect = self._max_bounds.intersection(neighbor_rect)
    for sub_i in range(contained_neighbor_rect.position.x, contained_neighbor_rect.end.x):
        var neighbor_i = sub_i - i + 1
        for sub_j in range(contained_neighbor_rect.position.y, contained_neighbor_rect.end.y):
            var neighbor_j = sub_j - j + 1
            neighboring_generators[neighbor_i][neighbor_j] = self.get_at(sub_i, sub_j)
    return neighboring_generators

func _shift_neighboring_generators_right(neighboring_generators, i, j):
    neighboring_generators.pop_front()
    neighboring_generators.push_back([null, null, null])
    if i + 1 < self._max_bounds.end.x:
        for sub_j in range(max(j - 1, self._max_bounds.position.y), min(j + 2, self._max_bounds.end.y)):
            var neighbor_j = sub_j - j + 1
            neighboring_generators[2][neighbor_j] = self.get_at(i + 1, sub_j)

func _shift_neighboring_generators_down(neighboring_generators, i, j):
    for neighbor_i in 3:
        neighboring_generators[neighbor_i].pop_front()
        neighboring_generators[neighbor_i].push_back(null)
    if j + 1 < self._max_bounds.end.y:
        for sub_i in range(max(i - 1, self._max_bounds.position.x), min(i + 2, self._max_bounds.end.x)):
            var neighbor_i = sub_i - i + 1
            neighboring_generators[neighbor_i][2] = self.get_at(sub_i, j + 1)

func _get_generate_bounds(uncontained_bounds: Rect2i):
    var uncontained_generate_bounds = self._get_rect_smaller_by(uncontained_bounds)
    return self._max_bounds.intersection(uncontained_generate_bounds)

func _get_rect_smaller_by(rect: Rect2i):
    return Rect2i(
        rect.position.x + self._generate_at_distance_from_x_sides,
        rect.position.y + self._generate_at_distance_from_y_sides,
        rect.size.x - self._generate_at_distance_from_x_sides * 2,
        rect.size.y - self._generate_at_distance_from_y_sides * 2
    )
