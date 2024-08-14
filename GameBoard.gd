extends Control

var grid_rows: int = 10  # Size of the grid
var grid_cols: int = 10
var num_of_mines: int = 10
var board_mines = []
var is_populated = false
var cell_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	$GridContainer.set_columns(grid_cols)
	cell_scene = preload("res://cell.tscn")
	_populate_board(num_of_mines)
	_set_cell_numbers()

# returns list of which cell indexes will be mines
func _generate_mine_list(mines):
	var mine_position = 0
	for i in mines:
		mine_position = randi_range(1, (grid_rows * grid_cols))
		while (mine_position in board_mines):
			mine_position = randi_range(1, (grid_rows * grid_cols))
		board_mines.append(mine_position)
	return board_mines

# determine how many cells adjacent to passed argument are mines.
# this counts the cell itself as adjacent cell, but this should not be a 
#  problem, as cells using this function are never mines themselves
func _count_adjacent_mines(cell):
	var adj_mine_count = 0
	var pos	
	
#region: Safety checks performed before running function
	# Exit function and return 0 if board has not yet been populated with cells
	if is_populated == false:
		print("Board has not been populated yet.")
		return 0
	
	# Check if we got a grid index or a (x,y) position, or exit if invalid arg
	if typeof(cell) == TYPE_INT:
		pos = get_cell_position(cell)
	elif typeof(cell) == TYPE_VECTOR2:
		pos = cell
	else:
		print("Invalid argument for _get_adjacent_mines()")
		return 0
#endregion
	
	for i in range(pos.x - 1, pos.x + 2):
		for j in range(pos.y - 1, pos.y + 2):
			if !((i < 0) or (j < 0) or (i > grid_rows - 1) or (j > grid_cols - 1)):
				var adjacent_cell = Vector2(i,j)
			# find out if this specific adjacent cell is a mine
				if ($GridContainer.get_child(get_cell_index(adjacent_cell)).is_mine):
					adj_mine_count += 1
	return adj_mine_count

func _populate_board(mines):
	var mine_cells = _generate_mine_list(mines)
	var count = 0
	for row in range(grid_rows):
		for col in range(grid_cols):
			count += 1
			var cell = cell_scene.instantiate()
			cell.custom_minimum_size = Vector2(30, 30)  # Set cell size
			if count in mine_cells:
				cell.load_mine(true)
			else:
				cell.load_mine(false)
			$GridContainer.add_child(cell)	
	is_populated = true;

func _set_cell_numbers():
	for i in (grid_rows * grid_cols):
		var cell = $GridContainer.get_child(i)
		if cell.is_mine == false:
			cell.load_number(_count_adjacent_mines(i))

#func _game_over():
	#for i in (board_mines):
		#var cell = $GridContainer.get_child(i)
		#cell._reveal()

#region: Auxiliary functions
# determine index of a certain cell by its row and column
func get_cell_index(cell_position):
	var index = cell_position.x * grid_cols + cell_position.y
	return index

# determine cell's (x,y) position in the grid by its index
func get_cell_position(index):
	var x = index / grid_rows
	var y = index % grid_cols
	return Vector2(x,y)
#endregion
