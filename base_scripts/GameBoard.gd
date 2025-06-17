class_name GameBoard
extends Control

var grid_rows: int
var grid_cols: int
var num_of_mines: int
var board_mines = []
var is_populated: bool = false
var cell_scene: PackedScene = preload("res://base_scripts/cell.tscn")
var open_cells: int = 0
var game_lost: bool = false
var cell_size = 30
var is_quick_reveal = false

signal flagged2
signal board_clear

#region Funções de criar novo quadro
# Recebe os parâmetros desejados para um novo quadro e o cria.
func load_new_board(rows,cols,mines: int,bg,flag,mine,stylebox):
	erase_old_board()
	grid_rows = rows
	grid_cols = cols
	num_of_mines = mines
	$ColorRect/GridContainer.set_columns(grid_rows)
	custom_minimum_size = Vector2(grid_rows*(cell_size + 4) + 5,grid_cols*(cell_size + 4) + 5)
	board_mines = []
	is_populated = false
	open_cells = 0
	game_lost = false
	$AudioStreamPlayer.stream = load('res://sounds/tap.wav')
	_populate_board(num_of_mines,bg,flag,mine,stylebox)
	_set_cell_numbers()
	set_qk_reveal_and_mines()

# Elimina o quadro presente na tela.
func erase_old_board():
	var cells = $ColorRect/GridContainer.get_children()
	for i in cells:
		i.queue_free()
		$ColorRect/GridContainer.remove_child(i)

# Retorna uma lista de quais índices de células serão minas.
func _generate_mine_list(mines):
	var mine_position = 0
	for i in mines:
		mine_position = randi_range(1, (grid_rows * grid_cols))
		while (mine_position in board_mines):
			mine_position = randi_range(1, (grid_rows * grid_cols))
		board_mines.append(mine_position)
	return board_mines

# Coloca as minas na posição apropriada de acordo com a lista gerada.
func _populate_board(mines:int,bg,flag,mine,stylebox):
	var mine_cells = _generate_mine_list(mines)
	var count = 0
	for row in range(grid_rows):
		for col in range(grid_cols):
			count += 1
			var cell = cell_scene.instantiate()
			cell.custom_minimum_size = Vector2(cell_size, cell_size)
			cell.cell_position.x = row
			cell.cell_position.y = col
			cell.flag_tx = flag
			cell.mine_tx = mine
			cell.bg_tx = bg
			cell.style_box = stylebox
			if count in mine_cells:
				cell.load_mine()
			$ColorRect/GridContainer.add_child(cell)
	is_populated = true;

# Com as minas colocadas, coloca números de acordo com quantas minas a célula
# tem adjacentes a ela.
func _set_cell_numbers() -> void:
	for i in (grid_rows * grid_cols):
		var cell = $ColorRect/GridContainer.get_child(i)
		if !cell.is_mine:
			cell.load_number(_count_adjacent_mines(cell))

# Conta quantas minas há em torno da célula. 
# O argumento deve ser o Node da célula de verdade, não o índice dela.
func _count_adjacent_mines(cell: Button) -> int:
	var count = 0
	var pos = cell.cell_position
	
	if !is_populated:
		print("O quadro ainda não foi populado.")
		return 0
	
	for i in range(pos.x - 1, pos.x + 2):
		for j in range(pos.y - 1, pos.y + 2):
			# Evitando sair dos limites do quadro:
			if !((i < 0) or (j < 0) or (i > grid_rows - 1) or (j > grid_cols - 1)):
				var adjacent_cell = $ColorRect/GridContainer.get_child(get_cell_index(Vector2(i,j)))
				if adjacent_cell.is_mine: count += 1
	if cell.is_mine: count -= 1
	return count

# Faz a conexão das células para revelação automática.
func set_qk_reveal_and_mines():
	for i in (grid_cols * grid_rows):
		var cell = $ColorRect/GridContainer.get_child(i-1)
		cell.connect("flagged",_on_flagged)
		cell.connect("reveal",_on_reveal)
		if !cell.is_mine:
			if !cell.adjacent_mines:
			# Todas as células adjacentes de Células sem número são seguras,
			# então nós podemos revelá-las para o jogador.
				cell.connect("attempt_quick_reveal",_reveal_adjacent)
			else:
				cell.connect("attempt_quick_reveal",_quick_reveal)

# Encontra uma célula em branco aleatória para sugerir como primeiro clique.
# Sem isto, o primeiro clique muitas vezes é um game over automático.
func _suggest_first_click():
	if !is_populated:
		return
	var cell = $ColorRect/GridContainer.get_child(randi_range(1, (grid_rows * grid_cols)-1))
	while (cell.is_mine or cell.adjacent_mines != 0):
		cell = $ColorRect/GridContainer.get_child(randi_range(1, (grid_rows * grid_cols)-1))	
	var new_stylebox_normal = cell.style_box.duplicate(true)
	new_stylebox_normal.set_border_width_all(3)
	new_stylebox_normal.border_color = Color(0, 0, 0)
	cell.add_theme_stylebox_override("normal", new_stylebox_normal)
	cell.firstclick = true

#endregion

#region Clique do jogador
# Para uso quando o jogador marcou o mesmo número de bandeiras que a célula 
# diz existirem, e então clica na célula.
# Revela minas também, se o jogador houver marcado incorretamente.
func _quick_reveal(cell: Button):
	var pos = cell.cell_position
	var count = 0
	for i in range(pos.x - 1, pos.x + 2):
		for j in range(pos.y - 1, pos.y + 2):
			if !((i < 0) or (j < 0) or (i > grid_rows - 1) or (j > grid_cols - 1)):
				var adjacent_cell = $ColorRect/GridContainer.get_child(get_cell_index(Vector2(i,j)))
				if adjacent_cell.is_flagged == 1:
					count += 1
	if count == cell.adjacent_mines:
		_reveal_adjacent(cell)
		_play("tap")

# Revela tudo em torno da célula.
func _reveal_adjacent(cell: Button):
	is_quick_reveal = true
	var pos = cell.cell_position
	for i in range(pos.x - 1, pos.x + 2):
		for j in range(pos.y - 1, pos.y + 2):
			if !((i < 0) or (j < 0) or (i > grid_rows - 1) or (j > grid_cols - 1)):
				var adjacent_cell = $ColorRect/GridContainer.get_child(get_cell_index(Vector2(i,j)))
				adjacent_cell._reveal()
	is_quick_reveal = false
#endregion

#region: Funções de controle de jogo
# Checa, a cada célula revelada, se é hora de finalizar o quadro.
func _on_reveal(is_mine):
	open_cells += 1
	if !is_mine and !is_quick_reveal:
		_play("tap")
	
	if is_mine and !game_lost:
		game_lost = true
		for i in board_mines:
			$ColorRect/GridContainer.get_child(i-1)._reveal()
		board_clear.emit(true)
	
	elif open_cells == (grid_rows * grid_cols - num_of_mines) and !game_lost:
		board_clear.emit(false)

# Sinal emitido para o contador de bandeiras capturar.
func _on_flagged(flag):
	flagged2.emit(int(flag))
#endregion

#region: Funções auxiliares
# Toca som
func _play(sound:String) -> void:
	sound = "res://sounds/" + sound + ".wav"
	if AudioControl.on:
		$AudioStreamPlayer.stream = load(sound)
		$AudioStreamPlayer.play()

# Faz o efeito sonoro não ser cortado antes de terminar de tocar.
func _wait() -> void:
	if AudioControl.on:
		await $AudioStreamPlayer.finished

# determina índice de determinada célula por sua linha e coluna
func get_cell_index(cell_position: Vector2) -> int:
	var index = cell_position.x * grid_cols + cell_position.y
	return index

# determina posição (x,y) da célula na grade pelo seu índice
func get_cell_position(index) -> Vector2:
	var x = index / grid_rows
	var y = index % grid_cols
	return Vector2(x,y)
#endregion
