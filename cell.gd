extends Button

var adjacent_mines: int = 0
var is_mine: bool = false
var is_open: bool = false
var is_flagged: bool = false
var skin = "default"
var cell_position: Vector2
signal blank
signal reveal
signal gameover

func _ready():
	$Label.hide()
	$cell_bg.texture = load("res://art/skin_" + str(skin) + "/cell_bg.png")
	expand_icon = true

func load_mine(mine):
	is_mine = mine
	if (is_mine):
		$cell_graphics.texture = load("res://art/skin_" + str(skin) + "/mine_default.png")

func load_number(count):
	adjacent_mines = count
	if adjacent_mines and !is_mine:
		$cell_graphics.texture = null
		$Label.text = str(adjacent_mines)

func _reveal():
	if !(is_flagged) and !(is_open):
		get_parent().get_parent()._monitor_win_condition()
		$cell_graphics.show()
		$cell_bg.show()
		$Label.show()
		is_open = true
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
