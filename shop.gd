extends PanelContainer

@export var inv: Inv
var invslot_scene: PackedScene = preload("res://inventory/shop_inv_slot.tscn")
var invslot_array: Array[Node]
var purchase_attempt
var items_in_inventory = 0

signal item_bought
signal item_used

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_fill_item_list()

func _fill_item_list():
	var inv_slot
	for i in inv.items.size():
		if inv.items[i] == null:
			continue
		inv_slot = invslot_scene.instantiate()
		inv_slot.find_child("Label").text = "$" + str(inv.items[i].price)
		inv_slot.find_child("Button").text = inv.items[i].name
		inv_slot.find_child("Button").icon = inv.items[i].texture
		inv_slot.item_function = 'shop'
		inv_slot.index = i
		# Conecta o sinal que cada item da loja pode emitir (quando há
		# tentativa de compra) à função que irá interagir com o inventário e o resto
		# do jogo
		inv_slot.connect("item_bought",_on_item_bought)
		$VBoxContainer/HBoxContainer/ScrollContainer/ShopItemList.add_child(inv_slot)

func _on_item_bought(index):
	# Esta função deve ser chamada apenas se o botão do item puder ser pressionado
	# Caso o item não esteja disponível, o botão deve estar desabilitado.
	var price
	price = inv.items[index].price
	print(str(price))
	if price > get_parent().coins:
		print("not enough money")
		# play a sound here
	else:
		purchase_attempt = index
		var confirm_window = load('res://inventory/confirm_purchase.tscn').instantiate()
		add_child(confirm_window)
		confirm_window.connect("confirmed",_on_confirm_purchase_confirmed)
		confirm_window.connect("canceled",_on_confirm_purchase_canceled)
		confirm_window._set_item(inv.items[index])
		confirm_window.visible = true
		# diminuir # de moedas -> GameManager
		# adicionar o item aos disponíveis
		
func _on_confirm_purchase_confirmed() -> void:
	item_bought.emit(inv.items[purchase_attempt])
	$VBoxContainer/HBoxContainer/ScrollContainer/ShopItemList.get_child(purchase_attempt).find_child("Label").text = '-'
	$VBoxContainer/HBoxContainer/ScrollContainer/ShopItemList.get_child(purchase_attempt).find_child("Button").disabled = true
	_add_to_inventory(inv.items[purchase_attempt])

func _add_to_inventory(item):
	var inv_slot = invslot_scene.instantiate()
	inv_slot.find_child("Label").text = ""
	inv_slot.find_child("Button").text = item.name
	inv_slot.find_child("Button").icon = item.texture
	inv_slot.index = items_in_inventory
	items_in_inventory += 1
	inv_slot.item_function = 'inventory'
	inv_slot.connect("item_used",_on_item_used)
	$VBoxContainer/HBoxContainer/InventoryContainer/InventoryList.add_child(inv_slot)

func _on_item_used(index):
	var inv_slot = $VBoxContainer/HBoxContainer/InventoryContainer/InventoryList
	inv_slot.get_child(index).find_child("Label").text = "Em uso"
	item_used.emit(inv.items[index])

func _on_confirm_purchase_canceled() -> void:
	pass # Replace with function body.

func _on_exit_to_menu_pressed() -> void:
	visible = false
