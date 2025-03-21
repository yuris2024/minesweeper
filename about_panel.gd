extends PopupPanel


func _on_sobre_pressed() -> void:
	visible = true

func _on_close_requested() -> void:
	visible = false
