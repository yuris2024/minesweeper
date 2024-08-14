extends Button

var adjacent_mines: int = 0
var is_mine: bool
var is_open: bool = false
var skin = "default"
var cell_position: Vector2

func _ready():
	expand_icon = true

func load_mine(mine):
	is_mine = mine
	if (is_mine):
		icon = load("res://art/skin_" + str(skin) + "/mine_default.png")

func load_number(num):
	adjacent_mines = num
	if (num != 0 and is_mine == false):
		$Label.text = str(adjacent_mines)
