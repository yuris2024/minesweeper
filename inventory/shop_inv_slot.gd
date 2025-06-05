extends ColorRect
class_name InvSlot

@export var index: int
var item_function
@export var item: InvItem

signal item_bought
signal item_used

func change_appearance(label, button_text, button_icon):
	find_child("Label").text = label
	find_child("Button").text = button_text
	find_child("Button").icon = button_icon
	find_child("Lock").text = "Nv. " + str(item.unlock_level)

func set_appearance():
	find_child("Label").text = ""
	find_child("Button").text = item.name
	find_child("Button").icon = item.texture
	unlock()

func unlock():
	find_child("Lock").icon = ImageTexture.new()
	find_child("Lock").text = ""
	print("Trying to unlock")

# 	Quando há uma tentativa de comprar o item, ele emite um sinal informando
# qual é o seu lugar na fila.
func _on_button_pressed() -> void:
	match item_function:
		'shop':
			item_bought.emit(item.name)
		'inventory':
			item_used.emit(item.name)
