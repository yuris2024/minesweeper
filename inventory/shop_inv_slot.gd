extends ColorRect

@export var index: int
var item_function

signal item_bought
signal item_used

# 	Quando há uma tentativa de comprar o item, ele emite um sinal informando
# qual é o seu lugar na fila.
func _on_button_pressed() -> void:
	match item_function:
		'shop':
			item_bought.emit(index)
		'inventory':
			item_used.emit(index)
