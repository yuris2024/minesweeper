extends PanelContainer

@export var inv: Inv
var invslot_scene: PackedScene = preload("res://inventory/shop_inv_slot.tscn")

signal item_bought

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
		inv_slot.index = i
		# Conecta o sinal que cada item da loja pode emitir (quando há
		# tentativa de compra) à função que irá interagir com o inventário e o resto
		# do jogo
		inv_slot.connect("item_bought",_on_item_bought)
		$VBoxContainer/HBoxContainer/ScrollContainer/ShopItemList.add_child(inv_slot)

func _on_item_bought(index):
	# Esta função deve ser chamada apenas se o botão do item puder ser pressionado
	# Caso o item não esteja disponível, o botão deve estar desabilitado.
	# 
	# Verificar se possui dinheiro suficiente.
		# Se não, não fazer nada.
		# Se sim:
			
	var price
	price = inv.items[index].price
	print(str(price))
	if price > get_parent().coins:
		print("not enough money")
	else:
		# ask for confirmation, maybe
		# diminuir # de moedas
		# adicionar o item aos disponíveis
		# desabilitar o botão na loja
		# mudar os gráficos/texto na loja p/ mostrar que não está mais em estoque
		item_bought.emit(price) # 

func _on_exit_to_menu_pressed() -> void:
	visible = false
