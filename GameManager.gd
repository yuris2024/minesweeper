extends Node
var time = 0
var board_scene: PackedScene = preload("res://GameBoard.tscn")
@onready var board_container = $Panel/Vboxcontainer/MarginContainer/BoardContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	$Panel/Vboxcontainer/HBoxContainer2/NewGameButton.process_mode = Node.PROCESS_MODE_ALWAYS

func _on_new_game_button_pressed():
	# remove old board first
	var children = board_container.get_children()
	for i in children:
		if !(i is GameBoard):
			continue
		i.queue_free()
		board_container.remove_child(i)
	
	get_tree().paused = false
	time = 0
	$Timer.start() # CHANGE THIS SO IT STARTS ONLY AFTER PLAYER'S FIRST CLICK
	
	# Generate board
	var new_board = board_scene.instantiate()
	new_board.load_new_board(10,10,10)
	board_container.add_child(new_board)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_timer_timeout():
	time += 1
	var label = $Panel/Vboxcontainer/HBoxContainer2/HBoxContainer/TimeCounter
	if time < 10:
		label.text = "00" + str(time)
	elif time >= 10 and time < 100:
		label.text = "0" + str(time)
	else:
		label.text = str(time)
