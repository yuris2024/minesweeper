extends Control

func _on_novo_jogo_pressed() -> void:
	get_tree().change_scene_to_file('res://base_scripts/GameManager.tscn')


func _on_continua_pressed() -> void:
	# read saved data...
	# feed to gamemanager...
	get_tree().change_scene_to_file('res://base_scripts/GameManager.tscn')
