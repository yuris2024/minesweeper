extends Control

func _ready():
	if AudioControl.on:
		$toggle_sound.button_pressed = true
	else:
		$toggle_sound.button_pressed = false

func _play(sound:String):
	sound = "res://sounds/" + sound + ".wav"
	if AudioControl.on:
		$AudioStreamPlayer.stream = load(sound)
		$AudioStreamPlayer.play()

func _wait():
	if AudioControl.on:
		await $AudioStreamPlayer.finished

#region salvar
var save_file_path = "user://data"
var save_file_name = "save.tres"
#
var save_data = SaveData.new()

func _on_continua_pressed() -> void:
	_play("click")
	# Carrega o jogo salvo.
	save_data = ResourceLoader.load(save_file_path + save_file_name).duplicate(true)
	_wait()
	get_tree().change_scene_to_file('res://base_scripts/GameManager.tscn')
#endregion

func _on_novo_jogo_pressed() -> void:
	_play("click")
	_wait()
	# Confirmar se é pra deletar o save antigo
	$ConfirmNewGame.visible = true

func _on_confirm_new_game_confirmed() -> void:
	# Trocar o save pelo save padrão
	save_data = ResourceLoader.load('res://save/default_save.tres').duplicate(true)
	ResourceSaver.save(save_data, save_file_path + save_file_name)
	# E continuar o jogo a partir desse save novo
	get_tree().change_scene_to_file('res://base_scripts/GameManager.tscn')

func _on_confirm_new_game_canceled() -> void:
	$ConfirmNewGame.visible = false

func _on_como_jogar_pressed() -> void:
	_play("click")
	_wait()
	get_tree().change_scene_to_file('res://HowToPlay.tscn')

func _on_recordes_pressed():
	_play("click")
	save_data = ResourceLoader.load(save_file_path + save_file_name).duplicate(true)
	$RecordsPanel.beginner = save_data.records[0]
	$RecordsPanel.intermediate = save_data.records[1]
	$RecordsPanel.advanced = save_data.records[2]
	$RecordsPanel.update_label()
	$RecordsPanel.visible = true

#func _on_save_pressed() -> void:
	##save_data.bg = 
	#ResourceSaver.save(save_data, save_file_path + save_file_name)
	#print("saved on " + save_file_path + save_file_name)

func _on_toggle_sound_toggled(toggled_on: bool):
	if toggled_on: 
		AudioControl.on = true
	else:
		AudioControl.on = false
