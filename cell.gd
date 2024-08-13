extends Button

var adjacent_mines: int = 0
var is_mine: bool
var is_open: bool
var skin

func _ready():
	pass # Replace with function body.

func _init(mine, adj):
	adjacent_mines = adj
	is_mine = mine
	is_open = false
	if (is_mine):
		icon = load("res://art/skin_" + str(skin) + "/mine_default.png")
