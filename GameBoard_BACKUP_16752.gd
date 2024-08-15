extends Control

<<<<<<< HEAD
var grid_rows: int
var grid_cols: int
var num_of_mines: int
var board_mines = []
var is_populated: bool
var cell_scene: PackedScene = preload("res://cell.tscn")
var open_cells = 0
var game_lost = false
=======
var grid_rows: int = 10  # Size of the grid
var grid_cols: int = 10
var num_of_mines: int = 10
var board_mines = []
var is_populated = false
var cell_scene: PackedScene
var gameover = false
signal mine_clicked
>>>>>>> main

# Called when the node enters the scene tree for the first time.
func _ready():
	load_new_board(10,10,10)

func load_new_board(rows,cols,mines):
	var cells = $GridContainer.get_children()
	for i in cells:
		i.queue_free()
	grid_rows = rows
	grid_cols = cols
	num_of_mines = mines
	$GridContainer.set_columns(grid_cols)
	board_mines = []
	is_populated = false
	open_cells = 0
	game_lost = false
	_populate_board(num_of_mines)
	_set_cell_numbers()
	set_blank_and_mines()
	get_tree().paused = false

<<<<<<< HEAD
<<<<<<< HEAD
func _populate_board(num_mines):
	var mine_cells = _generate_mine_list(num_mines)
=======
=======
>>>>>>> parent of cd573e1 (Reset game board after win or loss)
# returns list of which cell indexes will be mines
func _generate_mine_list(mines):
	var mine_position = 0
	for i in mines:
		mine_position = randi_range(1, (grid_rows * grid_cols))
		while (mine_position in board_mines):
			mine_position = randi_range(1, (grid_rows * grid_cols))
		board_mines.append(mine_position)
	return board_mines

<<<<<<< HEAD
=======
func _monitor_win_condition():
	open_cells += 1
	if open_cells == (grid_rows * grid_cols - board_mines.size()) and game_lost == false:
		print("You win")
		get_tree().paused = true
		_reset_game()

func _on_gameover():
	game_lost = true
	for i in board_mines:
		$GridContainer.get_child(i-1)._reveal()
	print("You lose")
	get_tree().paused = true
	#_reset_game()

func _reset_game():
	load_new_board(10,10,10)
	

>>>>>>> parent of cd573e1 (Reset game board after win or loss)
# determine how many cells adjacent to passed argument are mines.
# this counts the cell itself as adjacent cell, but this should not be a 
#  problem, as cells using this function are never mines themselves
func _count_adjacent_mines(cell):
	var adj_mine_count = 0
	var pos	
<<<<<<< HEAD

	
=======
>>>>>>> parent of cd573e1 (Reset game board after win or loss)
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
<<<<<<< HEAD
	
=======
>>>>>>> parent of cd573e1 (Reset game board after win or loss)
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
<<<<<<< HEAD
>>>>>>> main
=======
>>>>>>> parent of cd573e1 (Reset game board after win or loss)
	var count = 0
	for row in range(grid_rows):
		for col in range(grid_cols):
			count += 1
			var cell = cell_scene.instantiate()
			cell.custom_minimum_size = Vector2(30, 30)  # Set cell size
			cell.cell_position.x = row
			cell.cell_position.y = col
			if count in mine_cells:
				cell.load_mine(true)
			else:
				cell.load_mine(false)
			$GridContainer.add_child(cell)
	is_populated = true;

func _set_cell_numbers():
	for i in (grid_rows * grid_cols):
		var cell = $GridContainer.get_child(i)
<<<<<<< HEAD
		if !cell.is_mine:
			cell.load_number(_count_adjacent_mines(cell))

<<<<<<< HEAD
func _count_adjacent_mines(cell): #Argument should be actual cell, not its index.
	var count = 0
	var pos = cell.cell_position
	
	if !is_populated:
		print("Board has not been populated yet.")
		return 0
	
	for i in range(pos.x - 1, pos.x + 2):
		for j in range(pos.y - 1, pos.y + 2):
			# Avoid going out of grid's bounds:
			if !((i < 0) or (j < 0) or (i > grid_rows - 1) or (j > grid_cols - 1)):
				var adjacent_cell = $GridContainer.get_child(get_cell_index(Vector2(i,j)))
				if (adjacent_cell.is_mine): count += 1
	if (cell.is_mine): count -= 1
	return count
=======
		if cell.is_mine == false:
			cell.load_number(_count_adjacent_mines(i))
>>>>>>> parent of cd573e1 (Reset game board after win or loss)

func set_blank_and_mines():
	for i in (grid_cols * grid_rows):
		var cell = $GridContainer.get_child(i-1)
		if cell.adjacent_mines == 0 and !cell.is_mine:
			cell.connect("blank",blank_cell)
		if i in board_mines:
			cell.connect("gameover",_on_gameover)

func blank_cell(cell):
	var pos = cell.cell_position
	for i in range(pos.x - 1, pos.x + 2):
		for j in range(pos.y - 1, pos.y + 2):
			if !((i < 0) or (j < 0) or (i > grid_rows - 1) or (j > grid_cols - 1)):
				var adjacent_cell = get_cell_index(Vector2(i,j))
				$GridContainer.get_child(adjacent_cell)._reveal()


<<<<<<< HEAD
func _on_gameover(): # Triggered when player reveals a mine cell.
	game_lost = true
	for i in board_mines:
		$GridContainer.get_child(i-1)._reveal()
	print("You lose")
	get_tree().paused = true
	_reset_game()
	
func _reset_game():
	load_new_board(10,10,10)
#endregion
=======
func _game_over():
	gameover = true
	for i in (board_mines):
		var cell = $GridContainer.get_child(i-1)
		cell._unhide()
>>>>>>> main
=======
		
>>>>>>> parent of cd573e1 (Reset game board after win or loss)

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


func _on_mine_clicked():
	_game_over()
