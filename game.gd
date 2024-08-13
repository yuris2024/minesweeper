extends Control

var grid_rows: int = 10  # Size of the grid
var grid_cols: int = 10
var cell_scene: PackedScene
var cell_list = []

# Called when the node enters the scene tree for the first time.
func _ready():
	$GridContainer.set_columns(grid_cols)
	cell_scene = preload("res://cell.tscn")
	_populate_board()

# define which cells will be mines
# func _define_board_config():
	

func _populate_board():
	for row in range(grid_rows):
		for col in range(grid_cols):
			var cell = cell_scene.instantiate()
			cell.custom_minimum_size = Vector2(30, 30)  # Set cell size
			cell.loadcell(true,0)
			$GridContainer.add_child(cell)
			# cell_list.append(cell)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
