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

func load_number(num):
	adjacent_mines = num

func _unhide():
	if (is_mine):
		icon = load("res://art/skin_" + str(skin) + "/mine_default.png")
		
	else:
		if (adjacent_mines != 0 and is_mine == false):
			$Label.text = str(adjacent_mines)
#
func _gui_input(event: InputEvent):
	if !(event is InputEventMouseButton) or !event.pressed:
		return
	if event.button_index == 1:
		_unhide()
	elif event.button_index == 2:
		print("flag")
