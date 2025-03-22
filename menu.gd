extends Control

#region save
var save_file_path = "user://data"
var save_file_name = "save.tres"
#
var save_data = SaveData.new()



func _on_continua_pressed() -> void:
	# read saved data...
	save_data = ResourceLoader.load(save_file_path + save_file_name).duplicate(true)
	print(str(save_data.coins))
	# feed to gamemanager...
	
	get_tree().change_scene_to_file('res://base_scripts/GameManager.tscn')

#func _on_save_pressed() -> void:
	##save_data.bg = 
	#ResourceSaver.save(save_data, save_file_path + save_file_name)
	#print("saved on " + save_file_path + save_file_name)

#endregion

func _on_novo_jogo_pressed() -> void:
	get_tree().change_scene_to_file('res://base_scripts/GameManager.tscn')

func _on_como_jogar_pressed() -> void:
	get_tree().change_scene_to_file('res://HowToPlay.tscn')


func _on_recordes_pressed():
	save_data = ResourceLoader.load(save_file_path + save_file_name).duplicate(true)
	$RecordsPanel.beginner = save_data.records[0]
	$RecordsPanel.intermediate = save_data.records[1]
	$RecordsPanel.advanced = save_data.records[2]
	$RecordsPanel.update_label()
	$RecordsPanel.visible = true
	
	
	
