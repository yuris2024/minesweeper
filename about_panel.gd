extends PopupPanel


func _on_sobre_pressed() -> void:
	get_parent().get_child(0).stream = load("res://sounds/click.wav")
	get_parent().get_child(0).play()
	visible = true

func _on_close_requested() -> void:
	visible = false

# Sound Credits
# Videogame Menu Button Clicking Sound 12 by Christopherderp -- https://freesound.org/s/333039/ -- License: Creative Commons 0
