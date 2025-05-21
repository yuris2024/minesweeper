extends Control

func _on_voltar_pressed() -> void:
	$AudioStreamPlayer.stream = load("res://sounds/click.wav")
	$AudioStreamPlayer.play()
	await $AudioStreamPlayer.finished
	get_tree().change_scene_to_file('res://menu.tscn')
