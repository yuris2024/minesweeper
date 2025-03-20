extends Button

var adjacent_mines: int = 0
var is_mine: bool = false
var is_open: bool = false
var is_flagged: int = 0
var cell_position: Vector2
var firstclick: bool = false
@export var style_box: StyleBoxFlat
#CHANGE GRAPHICS TO THIS STYLE BOX!

signal gameover
signal attempt_quick_reveal
signal flagged
signal reveal

func _ready():
	add_theme_stylebox_override("normal",style_box)
	expand_icon = true
	$cell_bg.texture = load("res://art/skin_default/cell_bg.png")

func load_mine():
	# Torna célula uma mina.
	is_mine = true
	$cell_graphics.texture = load("res://art/skin_default/mine_default.png")

func load_number(num):
	# Torna célula numérica.
	adjacent_mines = num
	if adjacent_mines != 0 and !is_mine:
		$Label.hide()
		$Label.text = str(adjacent_mines)

func _reveal():
	# Revela a célula e, caso aplicável, as adjacentes.
	if !is_flagged and !is_open:
		reveal.emit(is_mine)
		# get_parent().get_parent().get_parent()._monitor_win_condition()
		is_open = true
		$cell_graphics.show()
		$cell_bg.show()
		$Label.show()
		if adjacent_mines == 0: 
			attempt_quick_reveal.emit(self)
	if firstclick:
		style_box.set_border_width_all(0)
		# É a célula quem informa que foi clicada e o jogo está perdido.
#		if is_mine and !get_parent().get_parent().get_parent().game_lost:
#			gameover.emit()

func _gui_input(event: InputEvent):
	#    Administra o clique normal (revelar) ou com o botão direito (marcação
	# das células).
	#    Célula emite sinal ao ser marcada ou desmarcada, para que o contador
	# de bandeiras possa contá-la.
	if !(event is InputEventMouseButton) or !event.pressed:
		return
	
	# Clique com botão esquerdo: revela a célula
	if event.button_index == 1:

		if !is_flagged:
			if is_open:
				attempt_quick_reveal.emit(self)
			else:
				_reveal()
	
	# Clique com botão direito
	elif event.button_index == 2:
		# Primeiro clique direito: coloca bandeira
		if !is_flagged and !is_open:
			icon = load("res://art/skin_default/flag.png")
			is_flagged = 1
			flagged.emit(1)
		
		# Segundo clique direito: coloca interrogação
		elif is_flagged == 1 and !is_open:
			icon = load("res://art/skin_default/qmark.png")
			is_flagged = 2
			flagged.emit(-1)
		
		# Terceiro clique direito: remove marcação
		else:
			icon = null
			is_flagged = 0
