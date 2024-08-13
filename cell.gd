extends Button

var adjacent_mines: int = 0
var is_mine: bool
var is_open: bool
var skin = "default"
var cell_position: Vector2

func _ready():
	expand_icon = true

func loadcell(mine, adj):
	adjacent_mines = adj
	is_mine = mine
	is_open = false

	if (is_mine):
		icon = load("res://art/skin_" + str(skin) + "/mine_default.png")
