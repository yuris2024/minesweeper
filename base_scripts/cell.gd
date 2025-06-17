extends Button

var adjacent_mines: int = 0
var is_mine: bool = false
var is_open: bool = false
var is_flagged: int = 0
var cell_position: Vector2
var firstclick: bool = false
var style_box: StyleBoxFlat
var bg_tx = load("res://art/skin_default/cell_bg.png")
var mine_tx = load("res://art/skin_default/mine_default.png")
var flag_tx = load("res://art/skin_default/flag.png")

signal attempt_quick_reveal
signal flagged
signal reveal

# Chamada automaticamente quando o objeto (a célula) entra em cena.
func _ready():
	# Define aparência da célula
	add_theme_stylebox_override("normal",style_box)
	expand_icon = true
	$cell_bg.texture = bg_tx

# Torna célula uma mina.
func load_mine():
	is_mine = true
	$cell_graphics.texture = mine_tx

# Torna célula numérica.
func load_number(num):	
	adjacent_mines = num
	if adjacent_mines != 0 and !is_mine:
		$Label.hide()
		$Label.text = str(adjacent_mines)

# Revela a célula e, caso aplicável, as adjacentes.
func _reveal():
	if !is_flagged and !is_open:
		reveal.emit(is_mine)
		is_open = true
		$cell_graphics.show()
		$cell_bg.show()
		$Label.show()
		if adjacent_mines == 0: 
			attempt_quick_reveal.emit(self)
	if firstclick:
		style_box.set_border_width_all(0)

#   Administra o clique normal (revelar) ou com o botão direito (marcação
# das células).
func _gui_input(event: InputEvent):
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
			icon = flag_tx
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
