extends ColorRect

@export var index: int
var item_function
@export var item: InvItem

signal item_bought
signal item_used

func set_appearance():
	find_child("Label").text = ""
	find_child("Button").text = item.name
	find_child("Button").icon = item.texture

# 	Quando há uma tentativa de comprar o item, ele emite um sinal informando
# qual é o seu lugar na fila.
func _on_button_pressed() -> void:
	match item_function:
		'shop':
			item_bought.emit(index)
		'inventory':
			item_used.emit(index)
