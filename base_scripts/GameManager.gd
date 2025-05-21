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

func _ready():
	verify_save_directory(save_file_path)
	load_save()
	$Panel/Vboxcontainer/HBoxContainer2/NewGameButton.process_mode = Node.PROCESS_MODE_ALWAYS
	connect_shop()

#region loja
# Conecta sinais à loja
func connect_shop():
	$Shop.connect("item_bought",_on_item_bought)
	$Shop.connect("item_used",_on_item_used)
	
func _on_item_bought(item: InvItem):
	if !loading:
		var price = item.price
		_add_coins(-1*price)
	inv.append(item)
	
func _on_item_used(item: InvItem):
	_set_graphics(item)

func _set_graphics(item:InvItem):
	match item.type:
		'mine':
			mine_texture = item.texture
		'flag':
			flag_texture = item.texture
		'bg':
			bg_texture = item.texture
			style_box = item.style_box
#endregion

#region salvar

func verify_save_directory(path : String):
	DirAccess.make_dir_absolute(path)

func load_save():
	save_data = ResourceLoader.load(save_file_path + save_file_name).duplicate(true)
	_set_coins(save_data.coins)
	_set_difficulty(save_data.difficulty)
	experience = save_data.experience
	# carregando o inventário
	inv = save_data.inventory
	loading = true
	$Shop.loading = true
	for item in inv:
		$Shop._on_item_bought(item.name)
	loading = false
	$Shop.loading = false

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

#region: Board Control
func _set_difficulty(diff):
	#    Associa dificuldade escolhida com o número de linhas, colunas e minas 
	# predefinido.
	difficulty = diff
	match diff:
		1:
			current_rows = 9
			current_cols = 9
			current_mines = 10
		2:
			current_rows = 16
			current_cols = 16
			current_mines = 40
		3:
			current_rows = 30
			current_cols = 16
			current_mines = 99
		_:
			print("Erro estabelecendo dificuldade")

func _on_new_game_button_pressed():
	$AudioStreamPlayer.stream = load("res://sounds/click.wav")
	$AudioStreamPlayer.play()
	$Timer.stop()
	_set_timer(0)
	await $AudioStreamPlayer.finished
	$Timer.start()
	request_new_board(current_rows, current_cols, current_mines)
	get_tree().paused = false
	
	cells_to_flag = current_mines
	$Panel/Vboxcontainer/HBoxContainer2/HBoxContainer/FlagCounter.text = format_counter(cells_to_flag)

func remove_old_board():
	# Deleta todas as células criadas anteriormente no quadro.
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

func request_new_board(rows, cols, mines):
	# Cria um novo quadro.
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

func _set_timer(time_local):
	time = time_local
	$Panel/Vboxcontainer/HBoxContainer2/HBoxContainer/TimeCounter.text = format_counter(time_local)

func _set_flagger(flag):
	$Panel/Vboxcontainer/HBoxContainer2/HBoxContainer/FlagCounter.text = format_counter(flag)

func _on_flagged2(flag):
	cells_to_flag -= flag
	if cells_to_flag >= 0:
		_set_flagger(cells_to_flag)

func _set_coins(qty):
	coins = qty
	$Panel/Vboxcontainer/Header/ShopButton/CoinCounter.text = _format_coins(coins)
	$Shop/VBoxContainer/Header/Label.text = _format_coins(coins)

func _add_coins(qty):
	_set_coins(coins + qty)

func _format_coins(qty) -> String:
	return '$' + str(qty)

func format_counter(num):
	if num < 10:
		return "00" + str(num)
	elif num >= 10 and num < 100:
		return "0" + str(num)
	else:
		return str(num)

#endregion

func _on_board_clear(game_lost):
	if game_lost:
		$AudioStreamPlayer.stream = load('res://sounds/explode.wav')
		$AudioStreamPlayer.play()
		$BoardClearPopup.dialog_text = "Você perdeu"
	else:
		$BoardClearPopup.dialog_text = "Você ganhou"
		var board_coin_value = difficulty * 10
		_add_coins(board_coin_value)
		write_save(time)
	
	
	$BoardClearPopup.visible = true
	$Timer.stop()
	await $AudioStreamPlayer.finished
	get_tree().paused = true
	

#region Janelas
func _on_shop_button_pressed() -> void:
	$AudioStreamPlayer.stream = load("res://sounds/click.wav")
	$AudioStreamPlayer.play()
	await $AudioStreamPlayer.finished
	$Shop.visible = true
	#shop_open = true

func _on_board_clear_popup_confirmed() -> void:
	remove_old_board()

func _on_exit_to_menu_pressed() -> void:
	$AudioStreamPlayer.stream = load("res://sounds/click.wav")
	$AudioStreamPlayer.play()
	await $AudioStreamPlayer.finished
	get_tree().change_scene_to_file('res://menu.tscn')
	
func _on_shop_exit_shop_pressed() -> void:
	$AudioStreamPlayer.stream = load("res://sounds/click.wav")
	$AudioStreamPlayer.play()
	await $AudioStreamPlayer.finished
	write_save(null)
#endregion
