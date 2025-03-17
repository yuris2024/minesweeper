extends PanelContainer

@export var inv: Inv
var invslot_scene: PackedScene = preload("res://inventory/shop_inv_slot.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	iterate()

func iterate():
	var inv_slot
	for i in 4:
		# we gotta instantiate one at a time, attach the resource, then connect 
		# the signals
		inv_slot = invslot_scene.instantiate()
		
		inv_slot.find_child("Label").text = "$" + str(inv.items[i].price)
		inv_slot.find_child("Button").text = inv.items[i].name
		inv_slot.find_child("Button").icon = inv.items[i].texture
		# Conecta o sinal que cada item da loja pode emitir (quando há
		# tentativa de compra) à função que irá interagir com o inventário e o resto
		# do jogo
		inv_slot.connect("item_bought",_on_item_bought)
		$VBoxContainer/HBoxContainer/ScrollContainer/ShopItemList.add_child(inv_slot)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_item_bought(flag):
	# Esta função deve ser chamada apenas se o botão do item puder ser pressionado
	# Caso o item não esteja disponível, o botão deve estar desabilitado.
	# 
	# Verificar se possui dinheiro suficiente.
		# Se não, não fazer nada.
		# Se sim:
			# diminuir # de moedas
			# adicionar o item aos disponíveis
			# desabilitar o botão na loja
			# mudar os gráficos/texto p/ mostrar que não está mais em estoque
	pass

func _on_exit_to_menu_pressed() -> void:
	visible = false
