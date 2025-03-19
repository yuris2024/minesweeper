extends ColorRect

signal item_bought
@export var index: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# 	Quando há uma tentativa de comprar o item, ele emite um sinal informando
# qual é o seu lugar na fila.
func _on_button_pressed() -> void:
	item_bought.emit(index)
