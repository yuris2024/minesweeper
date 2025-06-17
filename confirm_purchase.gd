extends ConfirmationDialog
var item

# Janelinha de confirmar se deseja comprar ou não.

func _set_item(item_purchased):
	item = item_purchased
	dialog_text = "Comprar " + item.name + " por $" + str(item.price) + "?"
