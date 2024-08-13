extends Button

var adjacent_mines: int = 0
var is_mine: bool
var is_open: bool
var skin = "default"


func _ready():
	pass # Replace with function body.

func loadcell(mine, adj):
	adjacent_mines = adj
	is_mine = mine
	is_open = false
	expand_icon = true
	if (is_mine):
		icon = load("res://art/skin_" + str(skin) + "/mine_default.png")
