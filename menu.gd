extends Control

# Chamada automaticamente quando o objeto (o menu principal) entra em cena. 
func _ready():
	# Gerencia o botão de som ligado/desligado.
	if AudioControl.on:
		$toggle_sound.button_pressed = true
	else:
		$toggle_sound.button_pressed = false

# Toca determinado som. Se o áudio estiver desligado, não faz nada.
func _play(sound:String):
	sound = "res://sounds/" + sound + ".wav"
	if AudioControl.on:
		$AudioStreamPlayer.stream = load(sound)
		$AudioStreamPlayer.play()

# Espera o som terminar de tocar antes de executar a próxima ação, impedindo que
# seja cortado no meio.
func _wait():
	if AudioControl.on:
		await $AudioStreamPlayer.finished

#region salvar
var save_file_path = "user://data"
var save_file_name = "save.tres"
#
var save_data = SaveData.new()

# Botão "continua". Puxa o jogo salvo para carregá-lo.
func _on_continua_pressed() -> void:
	_play("click")
	# Carrega o jogo salvo.
	save_data = ResourceLoader.load(save_file_path + save_file_name).duplicate(true)
	_wait()
	get_tree().change_scene_to_file('res://base_scripts/GameManager.tscn')
#endregion

# Botão "novo jogo".
func _on_novo_jogo_pressed() -> void:
	_play("click")
	_wait()
	# Confirmar se é pra deletar o save antigo
	$ConfirmNewGame.visible = true

# Quando confirmado que se quer deletar o save antigo, puxa o padrão e continua
# a partir dele.
func _on_confirm_new_game_confirmed() -> void:
	save_data = ResourceLoader.load('res://save/default_save.tres').duplicate(true)
	ResourceSaver.save(save_data, save_file_path + save_file_name)
	get_tree().change_scene_to_file('res://base_scripts/GameManager.tscn')

# Quando o jogador desiste de deletar. Não faz nada.
func _on_confirm_new_game_canceled() -> void:
	$ConfirmNewGame.visible = false

# Botão "como jogar". Leva até a janela do tutorial.
func _on_como_jogar_pressed() -> void:
	_play("click")
	_wait()
	get_tree().change_scene_to_file('res://HowToPlay.tscn')

# Botão "melhores tempos". Atualiza e mostra a janela de recordes.
func _on_recordes_pressed():
	_play("click")
	save_data = ResourceLoader.load(save_file_path + save_file_name).duplicate(true)
	$RecordsPanel.beginner = save_data.records[0]
	$RecordsPanel.intermediate = save_data.records[1]
	$RecordsPanel.advanced = save_data.records[2]
	$RecordsPanel.update_label()
	$RecordsPanel.visible = true

# Botão de ligar/desligar som.
func _on_toggle_sound_toggled(toggled_on: bool):
	if toggled_on: 
		AudioControl.on = true
	else:
		AudioControl.on = false
