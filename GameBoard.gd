extends Control

var grid_rows: int
var grid_cols: int
var num_of_mines: int
var board_mines = []
var is_populated: bool
var cell_scene: PackedScene = preload("res://cell.tscn")
var open_cells = 0
var game_lost = false

# Called when the node enters the scene tree for the first time.
func _ready():
	load_new_board(10,10,10)

#region: Board generation
func load_new_board(rows,cols,mines):
#Clearing board and its variables
	var cells = $GridContainer.get_children()
	for i in cells:
		i.queue_free()
		$GridContainer.remove_child(i)
	board_mines = []
	is_populated = false
	open_cells = 0
	game_lost = false

	grid_rows = rows
	grid_cols = cols
	num_of_mines = mines
	$GridContainer.set_columns(grid_cols)
	_populate_board(num_of_mines)
	_set_cell_numbers()
	set_blank_and_mines()
	get_tree().paused = false

func _populate_board(num_mines):
	var mine_cells = _generate_mine_list(num_mines)
	var count = 0
	for row in range(grid_rows):
		for col in range(grid_cols):
			count += 1
			var cell = cell_scene.instantiate()
			cell.custom_minimum_size = Vector2(30, 30)  # Set cell size
			cell.cell_position.x = row
			cell.cell_position.y = col
			cell.load_mine(count in mine_cells)
			$GridContainer.add_child(cell)
	is_populated = true;

# Randomly generates list of which cell should be mines, by GRID INDEX.
func _generate_mine_list(num_mines):
	var mine_position = 0
	for i in num_mines:
		mine_position = randi_range(1, (grid_rows * grid_cols))
		while (mine_position in board_mines):
			mine_position = randi_range(1, (grid_rows * grid_cols))
		board_mines.append(mine_position)
	return board_mines

func _set_cell_numbers():
	for i in (grid_rows * grid_cols):
		var cell = $GridContainer.get_child(i)
		if !cell.is_mine:
			cell.load_number(_count_adjacent_mines(cell))

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

func set_blank_and_mines():
	for i in (grid_cols * grid_rows):
		var cell = $GridContainer.get_child(i-1)
		if cell.adjacent_mines == 0 and !cell.is_mine:
			cell.connect("blank",_on_blank)
		if i in board_mines:
			cell.connect("gameover",_on_gameover)
#endregion

#region: Game control functions
func _on_blank(cell): # Blank cells mean all cells around them are safe, so when
	# clicked, we recursively reveal until all edges of the area are number cells.
	var pos = cell.cell_position
	for i in range(pos.x - 1, pos.x + 2):
		for j in range(pos.y - 1, pos.y + 2):
			if !((i < 0) or (j < 0) or (i > grid_rows - 1) or (j > grid_cols - 1)):
				var adjacent_cell = get_cell_index(Vector2(i,j))
				$GridContainer.get_child(adjacent_cell)._reveal()

func _monitor_win_condition(): # Triggered every cell reveal.
	# Mere flagging and unflagging should not trigger this.
	open_cells += 1
	if open_cells == (grid_rows * grid_cols - board_mines.size()) and !game_lost:
		print("You win")
		get_tree().paused = true
		_reset_game()

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

#region: Auxiliary functions
# determine index in grid, by its row and column
func get_cell_index(cell_position):
	return cell_position.x * grid_cols + cell_position.y

# determine cell's (x,y) position in grid, index
func get_cell_position(index):
	var x = index / grid_rows
	var y = index % grid_cols
	return Vector2(x,y)
#endregion
