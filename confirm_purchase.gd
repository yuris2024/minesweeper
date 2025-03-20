extends ConfirmationDialog
var item

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func _set_item(item_purchased):
	item = item_purchased
	dialog_text = "Comprar " + item.name + " por $" + str(item.price) + "?"
