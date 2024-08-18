extends Node
var time = 0
var board_scene: PackedScene = preload("res://GameBoard.tscn")
@onready var board_container = $Panel/Vboxcontainer/MarginContainer/BoardContainer
var current_rows = 10
var current_cols = 10
var current_mines = 10
var cells_flagged = 0
var cells_to_flag

# Called when the node enters the scene tree for the first time.
func _ready():
	$Panel/Vboxcontainer/HBoxContainer2/NewGameButton.process_mode = Node.PROCESS_MODE_ALWAYS

func _on_new_game_button_pressed():
	remove_old_board()
	time = 0
	$Timer.start() # CHANGE THIS SO IT STARTS ONLY AFTER PLAYER'S FIRST CLICK
	request_new_board(current_rows, current_cols, current_mines)
	get_tree().paused = false
	cells_to_flag = current_mines
	$Panel/Vboxcontainer/HBoxContainer2/HBoxContainer/FlagCounter.text = format_counter(cells_to_flag)

func remove_old_board():
	var children = board_container.get_children()
	for i in children:
		if !(i is GameBoard):
			continue
		i.queue_free()
		board_container.remove_child(i)

func request_new_board(rows, cols, mines):
	var new_board = board_scene.instantiate()
	new_board.load_new_board(rows,cols,mines)
	board_container.add_child(new_board)
	new_board.connect("flagged2",_on_flagged2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_timer_timeout():
	time += 1
	$Panel/Vboxcontainer/HBoxContainer2/HBoxContainer/TimeCounter.text = format_counter(time)

func _on_flagged2(flag):
	cells_to_flag -= flag
	$Panel/Vboxcontainer/HBoxContainer2/HBoxContainer/FlagCounter.text = format_counter(cells_to_flag)

func format_counter(num):
	if num < 10:
		return "00" + str(num)
	elif num >= 10 and num < 100:
		return "0" + str(num)
	else:
		return str(num)
