extends Node
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
var exp = 0
var shop_open = false

var mine_texture: Texture2D = preload('res://art/skin_default/mine_default.png')
var flag_texture: Texture2D = preload('res://art/skin_default/flag.png')
var bg_texture: Texture2D = preload('res://art/skin_default/cell_bg.png')

# Called when the node enters the scene tree for the first time.
func _ready():
	_set_difficulty(1)
	_add_coins(500)
	$Panel/Vboxcontainer/HBoxContainer2/NewGameButton.process_mode = Node.PROCESS_MODE_ALWAYS
	connect_shop()

#region shop
# connect to shop
func connect_shop():
	$Shop.connect("item_bought",_on_item_bought)
	$Shop.connect("item_used",_on_item_used)
	
func _on_item_bought(item: InvItem):
	print("item bought game manager")
	var price = item.price
	print("game manager" + str(price))
	_add_coins(-1*price)
	
func _on_item_used(item: InvItem):
	print("item used:" + item.name)
	_set_graphics(item)

func _set_graphics(item:InvItem):
	match item.type:
		'mine':
			mine_texture = item.texture
		'flag':
			flag_texture = item.texture
		'bg':
			bg_texture = item.texture

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
	$Timer.start() # CHANGE THIS SO IT STARTS ONLY AFTER PLAYER'S FIRST CLICK
	request_new_board(current_rows, current_cols, current_mines)
	# gonna change this so it unpauses as soon as we click an "ok" or something:
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
	new_board.load_new_board(rows,cols,mines,bg_texture,flag_texture,mine_texture)
	board_container.add_child(new_board)
	new_board.connect("flagged2",_on_flagged2)
	new_board.connect("board_clear",_on_board_clear)
	new_board._suggest_first_click()

#endregion

#region Counters
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

func _add_coins(qty):
	coins += qty
	_format_coins(coins)

func _format_coins(qty):
	$Panel/Vboxcontainer/Header/ShopButton/CoinCounter.text = '$' + str(qty)

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
		$BoardClearPopup.dialog_text = "Você perdeu"
		print("Você perdeu")
	else:
		$BoardClearPopup.dialog_text = "Você ganhou"
		print("Você ganhou")
		#calculate coin value
		var board_value = difficulty * 10
		_add_coins(board_value)
	get_tree().paused = true
	$BoardClearPopup.visible = true

#region Windows
func _on_shop_button_pressed() -> void:
	$Shop.visible = true
	shop_open = true

func _on_board_clear_popup_confirmed() -> void:
	remove_old_board()
#endregion
