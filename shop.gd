extends PanelContainer

var inv_size = 12

@export var inv: Inv

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func iterate(): # Conecta o sinal que cada item da loja pode emitir (quando há
	# tentativa de compra) à função que irá interagir com o inventário e o resto
	# do jogo
	var inv_slot
	for i in inv_size:
		inv_slot = $VBoxContainer/HBoxContainer/ScrollContainer/ShopItemList.get_child(i-1)
		inv_slot.connect("item_bought",_on_item_bought)


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
