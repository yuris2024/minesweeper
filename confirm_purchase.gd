extends ConfirmationDialog
var item

func _set_item(item_purchased):
	item = item_purchased
	dialog_text = "Comprar " + item.name + " por $" + str(item.price) + "?"
