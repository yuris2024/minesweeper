extends Button

var adjacent_mines: int = 0
var is_mine: bool
var is_open: bool = false
var is_flagged: bool = false
var skin = "default"
var cell_position: Vector2
signal gameover
signal blank

func _ready():
	expand_icon = true
	$cell_bg.texture = load("res://art/skin_" + str(skin) + "/cell_bg.png")


func load_mine(mine):
	if (mine):
		is_mine = true
		$cell_graphics.texture = load("res://art/skin_" + str(skin) + "/mine_default.png")

func load_number(num):
	adjacent_mines = num
	$cell_bg.texture = load("res://art/skin_" + str(skin) + "/cell_bg.png")
	if (adjacent_mines != 0 and is_mine == false):
		$Label.hide()
		$Label.text = str(adjacent_mines)

func _reveal():
	if !(is_flagged) and !(is_open):
		get_parent().get_parent()._monitor_win_condition()
		is_open = true
		$cell_graphics.show()
		$cell_bg.show()
		$Label.show()
		if adjacent_mines == 0:
			blank.emit(self)

func _gui_input(event: InputEvent):
	if !(event is InputEventMouseButton) or !event.pressed:
		return
	if event.button_index == 1:
		if (is_mine):
			gameover.emit()
		_reveal()
	elif event.button_index == 2:
		if !is_flagged and !is_open:
			icon = load("res://art/skin_" + str(skin) + "/flag.png")
			is_flagged = true
		else:
			icon = null
			is_flagged = false
