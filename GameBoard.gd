class_name GameBoard
extends Control

var grid_rows: int
var grid_cols: int
var num_of_mines: int
var board_mines = []
var is_populated: bool = false
var cell_scene: PackedScene = preload("res://cell.tscn")
var open_cells: int = 0
var game_lost: bool = false
@onready var gridcontainer_path = $ColorRect/GridContainer

signal flagged2
signal board_clear

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#load_new_board(grid_rows,grid_cols,num_of_mines)

func load_new_board(rows,cols,mines):
	var cells = $ColorRect/GridContainer.get_children()
	for i in cells:
		i.queue_free()
		$ColorRect/GridContainer.remove_child(i)
	grid_rows = rows
	grid_cols = cols
	num_of_mines = mines
	$ColorRect/GridContainer.set_columns(grid_cols)
	custom_minimum_size = Vector2(grid_cols*34 + 5,grid_rows*34 + 5)
	board_mines = []
	is_populated = false
	open_cells = 0
	game_lost = false
	_populate_board(num_of_mines)
	_set_cell_numbers()
	set_qk_reveal_and_mines()
	#get_tree().paused = false

# returns list of which cell indexes will be mines
func _generate_mine_list(mines):
	var mine_position = 0
	for i in mines:
		mine_position = randi_range(1, (grid_rows * grid_cols))
		while (mine_position in board_mines):
			mine_position = randi_range(1, (grid_rows * grid_cols))
		board_mines.append(mine_position)
	return board_mines

func _populate_board(mines):
	var mine_cells = _generate_mine_list(mines)
	var count = 0
	for row in range(grid_rows):
		for col in range(grid_cols):
			count += 1
			var cell = cell_scene.instantiate()
			cell.custom_minimum_size = Vector2(30, 30)  # Set cell size
			cell.cell_position.x = row
			cell.cell_position.y = col
			if count in mine_cells:
				cell.load_mine()
			$ColorRect/GridContainer.add_child(cell)
	is_populated = true;

func _set_cell_numbers():
	for i in (grid_rows * grid_cols):
		var cell = $ColorRect/GridContainer.get_child(i)
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
				var adjacent_cell = $ColorRect/GridContainer.get_child(get_cell_index(Vector2(i,j)))
				if adjacent_cell.is_mine: count += 1
	if cell.is_mine: count -= 1
	return count


func set_qk_reveal_and_mines():
	for i in (grid_cols * grid_rows):
		var cell = $ColorRect/GridContainer.get_child(i-1)
		cell.connect("flagged",_on_flagged)
		if !cell.is_mine:
			if !cell.adjacent_mines:
			# Blank cells have all safe adjacent cells, so let's go ahead and 
			# reveal them for the player.
				cell.connect("attempt_quick_reveal",_reveal_adjacent)
			else:
				cell.connect("attempt_quick_reveal",_quick_reveal)
		else:
			cell.connect("gameover",_on_gameover)

func _on_flagged(flag):
	flagged2.emit(int(flag))

func _quick_reveal(cell):
# Use when player has fully flagged a given number cell and clicks it.
# Reveals mines too (if the player has flagged incorrectly).
	var pos = cell.cell_position
	var count = 0
	for i in range(pos.x - 1, pos.x + 2):
		for j in range(pos.y - 1, pos.y + 2):
			if !((i < 0) or (j < 0) or (i > grid_rows - 1) or (j > grid_cols - 1)):
				var adjacent_cell = $ColorRect/GridContainer.get_child(get_cell_index(Vector2(i,j)))
				if adjacent_cell.is_flagged == 1:
					count += 1
	if count == cell.adjacent_mines:
		_reveal_adjacent(cell)

func _reveal_adjacent(cell):
	var pos = cell.cell_position
	for i in range(pos.x - 1, pos.x + 2):
		for j in range(pos.y - 1, pos.y + 2):
			if !((i < 0) or (j < 0) or (i > grid_rows - 1) or (j > grid_cols - 1)):
				var adjacent_cell = $ColorRect/GridContainer.get_child(get_cell_index(Vector2(i,j)))
				adjacent_cell._reveal()

#region: Game Control functions
#func _on_flagged(flag):
	#cells_flagged += flag

func _on_gameover(): # Triggered when player reveals a mine cell.
	game_lost = true
	for i in board_mines:
		$ColorRect/GridContainer.get_child(i-1)._reveal()
	print("You lose")
	get_tree().paused = true

func _monitor_win_condition(): # Checks on every reveal.
	open_cells += 1
	if open_cells == (grid_rows * grid_cols - num_of_mines) and !game_lost:
		print("You win")
		board_clear.emit()
		get_tree().paused = true
	
func _reset_game():
	load_new_board(10,10,10)
#endregion

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
