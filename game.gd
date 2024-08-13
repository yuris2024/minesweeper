extends Control

var grid_size: int = 10  # Size of the grid
var cell_scene: PackedScene
# var cell_list = []

# Called when the node enters the scene tree for the first time.
func _ready():
	$GridContainer.set_columns(grid_size)
	cell_scene = preload("res://cell.tscn")
	_populate_board()

func _populate_board():
	for row in range(grid_size):
		for col in range(grid_size):
			var cell = cell_scene.instantiate()
			cell.custom_minimum_size = Vector2(30, 30)  # Set cell size
			cell.loadcell(true,0)
			$GridContainer.add_child(cell)
			# cell_list.append(cell)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
