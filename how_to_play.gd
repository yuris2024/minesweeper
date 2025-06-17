extends Control

# Botão de voltar ao menu.
func _on_voltar_pressed() -> void:
	if AudioControl.on:
		$AudioStreamPlayer.stream = load("res://sounds/click.wav")
		$AudioStreamPlayer.play()
		await $AudioStreamPlayer.finished
	get_tree().change_scene_to_file('res://menu.tscn')
