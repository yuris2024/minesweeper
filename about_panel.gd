extends PopupPanel

# Botão "sobre" do menu principal
func _on_sobre_pressed() -> void:
	if AudioControl.on:
		get_parent().get_child(0).stream = load("res://sounds/click.wav")
		get_parent().get_child(0).play()
	visible = true

# Fechar a janelinha "sobre", clicando em qualquer lugar
func _on_close_requested() -> void:
	visible = false

# Sound Credits
# Videogame Menu Button Clicking Sound 12 by Christopherderp -- https://freesound.org/s/333039/ -- License: Creative Commons 0
# Videogame Menu BUTTON CLICK by Christopherderp -- https://freesound.org/s/342200/ -- License: Creative Commons 0
# Videogame Menu Button Clicking Sound 18 by Christopherderp -- https://freesound.org/s/333047/ -- License: Creative Commons 0
# Propane Explosion Designed by modusmogulus -- https://freesound.org/s/734100/ -- License: Creative Commons 0
# Victory sound - result-3.mp3 by DZeDeNZ -- https://freesound.org/s/522240/ -- License: Creative Commons 0
