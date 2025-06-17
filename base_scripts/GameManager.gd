extends Node
#region Variáveis de controle
var time = 0
var board_scene: PackedScene = preload("res://base_scripts/GameBoard.tscn")
@onready var board_container = $Panel/Vboxcontainer/MarginContainer/BoardContainer
var current_rows = 9
var current_cols = 9
var current_mines = 10
var difficulty = 1
var cells_flagged = 0
var cells_to_flag
var coins = 0
var experience = 0
var level = 1
var loading = false
var inv: Array[InvItem]
#endregion

#region Variáveis de salvar
var save_data = SaveData.new()
var save_file_path = "user://data"
var save_file_name = "save.tres"

#endregion

#region Texturas
var mine_texture: Texture2D = preload('res://art/skin_default/mine_default.png')
var flag_texture: Texture2D = preload('res://art/skin_default/flag.png')
var bg_texture: Texture2D = preload('res://art/skin_default/cell_bg.png')
var style_box: StyleBox = preload("res://inventory/items/Backgrounds/bg_grey.tres").style_box
#endregion

# Chamada automaticamente quando o objeto (a tela de jogo) entra em cena.
func _ready():
	verify_save_directory(save_file_path)
	$AudioStreamPlayer.set_process_mode(3)
	load_save()
	$Panel/Vboxcontainer/HBoxContainer2/NewGameButton.process_mode = Node.PROCESS_MODE_ALWAYS
	connect_shop()

# Toca som.
func _play(sound:String):
	if AudioControl.on:
		sound = "res://sounds/" + sound + ".wav"
		$AudioStreamPlayer.stream = load(sound)
		$AudioStreamPlayer.play()

#region loja
# Conecta sinais à loja
func connect_shop():
	$Shop.connect("item_bought",_on_item_bought)
	$Shop.connect("item_used",_on_item_used)

# Retira moedas do jogador quando uma compra é feita e inclui o item no inventário
func _on_item_bought(item: InvItem):
	if !loading:
		var price = item.price
		_add_coins(-1*price)
	inv.append(item)

# Sinal recebido quando se usa um item.
func _on_item_used(item: InvItem):
	_set_graphics(item)

# Muda aparência de acordo com o item usado.
func _set_graphics(item:InvItem):
	match item.type:
		'mine':
			mine_texture = item.texture
			$Panel/Vboxcontainer/HBoxContainer2/HBoxContainer/FlagCtIcon.texture = item.texture
		'flag':
			flag_texture = item.texture
		'bg':
			bg_texture = item.texture
			style_box = item.style_box
#endregion

#region salvar

func verify_save_directory(path : String):
	DirAccess.make_dir_absolute(path)

# Carrega o arquivo de save, aplicando os valores salvos ao jogo atual
func load_save():
	save_data = ResourceLoader.load(save_file_path + save_file_name).duplicate(true)
	_set_coins(save_data.coins)
	_set_difficulty(save_data.difficulty)
	_set_exp(save_data.experience)
	# carregando o inventário
	inv = save_data.inventory
	loading = true
	$Shop.loading = true
	for item in inv:
		$Shop._on_item_bought(item.name)
	loading = false
	$Shop.loading = false

# Escreve os valores relevantes no arquivo de save.
# Parâmetro _time: tempo utilizado para finalizar o último quadro.
func write_save(_time):
	save_data = ResourceLoader.load(save_file_path + save_file_name).duplicate(true)
	save_data.coins = coins
	save_data.experience = experience
	save_data.difficulty = difficulty
	save_data.inventory = inv
	if _time != null:
		if save_data.records[difficulty-1] > _time:
			save_data.records[difficulty-1] = _time
			print("Record updated")
	ResourceSaver.save(save_data, save_file_path + save_file_name)
#endregion

#region: Controle de Quadro
#    Associa dificuldade escolhida com o número de linhas, colunas e minas 
# predefinido.
# diff: 1 = iniciante; 2 = intermediário; 3 = avançado.
func _set_difficulty(diff):
	difficulty = diff
	match difficulty:
		1:
			current_rows = 8
			current_cols = 8
			current_mines = 9
		2:
			current_rows = 10
			current_cols = 10
			current_mines = 17
		3:
			current_rows = 16
			current_cols = 16
			current_mines = 32
		_:
			print("Erro estabelecendo dificuldade")

# Sinal recebido quando o jogador seleciona "novo quadro".
# Desencadeia a remoção do quadro antigo e criação do novo.
func _on_new_game_button_pressed():
	_play("click")
	$Timer.stop()
	_set_timer(0)
	_wait()
	$Timer.start()
	remove_old_board()
	request_new_board(current_rows, current_cols, current_mines)
	get_tree().paused = false
	
	cells_to_flag = current_mines
	$Panel/Vboxcontainer/HBoxContainer2/HBoxContainer/FlagCounter.text = format_counter(cells_to_flag)

# Deleta todas as células criadas anteriormente no quadro.
# Reseta tudo relacionado ao quadro: tempo e bandeiras também.
func remove_old_board():
	var children = board_container.get_children()
	for i in children:
		if !(i is GameBoard):
			continue
		i.queue_free()
		board_container.remove_child(i)
	_set_flagger(0)
	$Timer.stop()
	_set_timer(0)
	get_tree().paused = false

# Cria um novo quadro e o adiciona à tela de jogo.
func request_new_board(rows, cols, mines):
	var new_board = board_scene.instantiate()
	new_board.load_new_board(rows,cols,mines,bg_texture,flag_texture,mine_texture,style_box)
	board_container.add_child(new_board)
	new_board.connect("flagged2",_on_flagged2)
	new_board.connect("board_clear",_on_board_clear)
	new_board._suggest_first_click()

#endregion

#region Contadores
func _on_timer_timeout():
	_set_timer(time+1)

func _set_timer(time_local) -> void:
	time = time_local
	$Panel/Vboxcontainer/HBoxContainer2/HBoxContainer/TimeCounter.text = format_counter(time_local)

func _set_flagger(flag):
	$Panel/Vboxcontainer/HBoxContainer2/HBoxContainer/FlagCounter.text = format_counter(flag)
# Insere o novo valor de marcações que faltam no contador.

func _on_flagged2(flag):
# Sinal recebido quando o jogador clica com o botão direito em uma célula.
# flag: 1 = bandeira; -1 = interrogação; 0 = nada
# O objetivo é contar a quantidade de bandeiras para sabermos quantas célulam faltam
# ser marcadas; o segundo clique direito retira a bandeira para pôr o '?', por isso -1.
	cells_to_flag -= flag
	if cells_to_flag >= 0:
		_set_flagger(cells_to_flag)

func _set_coins(qty):
	coins = qty
	$Panel/Vboxcontainer/Header/ShopButton/CoinCounter.text = _format_coins(coins)
	$Shop/VBoxContainer/Header/Label.text = _format_coins(coins)

func _add_coins(qty):
	_set_coins(coins + qty)

func _set_exp(qty):
# Recebe o valor de experiência a ser atualizado, o insere onde precisa estar e
# altera o nível de acordo com ele.
	experience = qty
	var show_exp = 2 * (experience % 50)
	$Panel/Vboxcontainer/Header/CenterContainer/VBoxContainer/TextureProgressBar.value = show_exp
	level = floor(experience / 50 + 1)
	$Panel/Vboxcontainer/Header/CenterContainer/VBoxContainer/Level.text = "Nível: " + str(level)
	$Shop.update_level()

func _add_exp(qty):
	_set_exp(experience + qty)

func _format_coins(qty) -> String:
	return '$' + str(qty)

func format_counter(num):
# Adiciona zeros para manter um número com 3+ dígitos.
	if num < 10:
		return "00" + str(num)
	elif num >= 10 and num < 100:
		return "0" + str(num)
	else:
		return str(num)
#endregion

# Chamada quando o quadro é finalizado.
# game_lost: true se o jogador clicou numa mina; false se tiver aberto todas as
# células seguras.
func _on_board_clear(game_lost):
	if game_lost:
		_play("explode")
		_wait()
		$BoardClearPopup.dialog_text = "Você perdeu"
	else:
		_play("win")
		_wait()
		$BoardClearPopup.dialog_text = "Você ganhou"
		var board_coin_value = difficulty * 10
		var exp = difficulty * 10
		_add_exp(exp)
		_add_coins(board_coin_value)
		write_save(time)
	
	$BoardClearPopup.visible = true
	$Timer.stop()
	get_tree().paused = true

#region Janelas
# Botão de abrir loja.
func _on_shop_button_pressed() -> void:
	_play("click")
	_wait()
	$Shop.visible = true

# Chamada quando o jogador clica "ok" na janela de "você ganhou/perdeu".
# Apaga o quadro.
func _on_board_clear_popup_confirmed() -> void:
	remove_old_board()

# Botão de voltar ao menu inicial.
func _on_exit_to_menu_pressed() -> void:
	_play("click")
	_wait()
	get_tree().change_scene_to_file('res://menu.tscn')

# Botão de sair da loja.
func _on_shop_exit_shop_pressed() -> void:
	_play("click")
	_wait()
	# A função write_save recebe como parâmetro o tempo levado para completar o
	# quadro. Chamamos com "null" para salvar o que foi feito dentro da loja,
	# sem vincular a um quadro.
	write_save(null) 
#endregion

# Faz o efeito sonoro não ser cortado antes de terminar de tocar.
func _wait():
	if AudioControl.on:
		await $AudioStreamPlayer.finished

# Para testar níveis altos e poder comprar coisas sem precisar jogar.
#func _test_levels(_exp, _coins):
	#_add_exp(_exp)
	#_add_coins(_coins)

# Botão de alterar dificuldade do quadro.
func _on_option_button_item_selected(index: int) -> void:
	_set_difficulty(index+1)
