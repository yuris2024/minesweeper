extends PanelContainer

@onready var shop_item_list = $VBoxContainer/HBoxContainer/ScrollContainer/ShopItemList
@onready var inventory_list = $VBoxContainer/HBoxContainer/InventoryContainer/InventoryList
@export var inv: Inv
var invslot_scene: PackedScene = preload("res://inventory/shop_inv_slot.tscn")
var invslot_array: Array[InvItem]
var purchase_attempt
var items_in_inventory = 0
var loading = false

signal item_bought
signal item_used
signal exit_shop_pressed


func _ready() -> void:
	_fill_item_list()


func _fill_item_list():
	var inv_slot: InvSlot
	inv.add_to_dictionary()
	for i in inv.items.size():
		if inv.items[i] == null:
			continue
		inv_slot = invslot_scene.instantiate()
		inv_slot.item = inv.items[i]
		inv_slot.change_appearance("$" + str(inv.items[i].price), inv.items[i].name, inv.items[i].texture)
		
		inv_slot.item_function = 'shop'
		inv_slot.index = i
		# Conecta o sinal que cada item da loja pode emitir (quando há
		# tentativa de compra) à função que irá interagir com o inventário e o resto
		# do jogo
		inv_slot.connect("item_bought",_on_item_bought)
		shop_item_list.add_child(inv_slot)

func update_level():
	for i in shop_item_list.get_child_count():
		var slot = shop_item_list.get_child(i)
		if slot == null:
			continue
		if slot.item.unlock_level <= get_parent().level:
			slot.unlock()

func _on_item_bought(_name):
	# Esta função deve ser chamada apenas se o botão do item puder ser pressionado
	# Caso o item não esteja disponível, o botão deve estar desabilitado.
	purchase_attempt = inv.get_item(_name)
	# A variável "loading" é usada aqui para podermos usar o modelo de compra para
	# carregar o save, sem mexer nas moedas quando estivermos fazendo isso.
	
	if !loading and purchase_attempt.unlock_level > get_parent().level:
		# Nível muito baixo para comprar
		$AudioStreamPlayer.stream = load("res://sounds/hit.wav")
		$AudioStreamPlayer.play()
		#print("Nível muito baixo!")
		return
	
	if !loading and purchase_attempt.price > get_parent().coins:
		# Não tem dinheiro para comprar
		$AudioStreamPlayer.stream = load("res://sounds/hit.wav")
		$AudioStreamPlayer.play()
		return
	
	elif !loading:
		# Mostrar janela de confirmação para o usuário confirmar ou cancelar
		var confirm_window = load('res://inventory/confirm_purchase.tscn').instantiate()
		add_child(confirm_window)
		confirm_window.connect("confirmed",_on_confirm_purchase_confirmed)
		confirm_window.connect("canceled",_on_confirm_purchase_canceled)
		confirm_window._set_item(purchase_attempt)
		confirm_window.visible = true
		# diminuir # de moedas -> GameManager
		# adicionar o item aos disponíveis
	else:
		item_bought.emit(purchase_attempt)
		var slot = get_slot_node_by_item_name(shop_item_list,purchase_attempt.name)
		slot.find_child("Label").text = '-'
		slot.find_child("Button").disabled = true
		_add_to_inventory(purchase_attempt)


func get_slot_node_by_item_name(list,_name):
	for child in list.get_children():
		if child.item.name == _name:
			#print(child.item.name)
			return child


func _on_confirm_purchase_confirmed() -> void:
	item_bought.emit(purchase_attempt)
	var slot = get_slot_node_by_item_name(shop_item_list,purchase_attempt.name)
	slot.find_child("Label").text = '-'
	slot.find_child("Button").disabled = true
	_add_to_inventory(purchase_attempt)


func _add_to_inventory(item):
	var inv_slot = invslot_scene.instantiate()
	inv_slot.item = item
	inv_slot.set_appearance()
	items_in_inventory += 1
	inv_slot.index = items_in_inventory -1
	invslot_array.append(item)
	inv_slot.item_function = 'inventory'
	inv_slot.connect("item_used",_on_item_used)
	inventory_list.add_child(inv_slot)


func _on_item_used(_name):
	var slot = get_slot_node_by_item_name(inventory_list,_name)
	slot.find_child("Label").text = "Em uso"
	for i in inventory_list.get_children(): #iterando sobre os inv_slots...
		# "Tirar de uso" os outros itens do mesmo tipo.
		if i.item.type == slot.item.type and i.item.name != slot.item.name:
			i.find_child("Label").text = ""
	item_used.emit(slot.item)


func _on_confirm_purchase_canceled() -> void:
	pass 


func _on_exit_to_menu_pressed() -> void:
	visible = false
	exit_shop_pressed.emit()
