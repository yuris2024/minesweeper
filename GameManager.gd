extends Node
var time = 0
var board_scene: PackedScene = preload("res://GameBoard.tscn")
@onready var board_container = $Panel/Vboxcontainer/MarginContainer/BoardContainer
# Called when the node enters the scene tree for the first time.
func _ready():
	$Panel/Vboxcontainer/HBoxContainer2/NewGameButton.process_mode = Node.PROCESS_MODE_ALWAYS
	pass

func _on_new_game_button_pressed():
	var children = board_container.get_children()
	for i in children:
		if i is Button:
			continue
		i.queue_free()
		board_container.remove_child(i)
	get_tree().paused = false
	time = 0
	$Timer.start() # CHANGE THIS SO IT STARTS ONLY AFTER PLAYER'S FIRST CLICK
	var new_board = board_scene.instantiate()
	new_board.load_new_board(10,10,10)
	board_container.add_child(new_board)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	time += 1
	$Panel/Vboxcontainer/HBoxContainer2/Label.text = str(time)
