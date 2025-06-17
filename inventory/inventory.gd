extends Resource

class_name Inv

# Essencialmente uma coleção de itens. Não é usado somente para inventário no sentido
# de "posse do jogador"; também serve para listar a loja.

@export var items: Array[InvItem]
var items_map = {}

# Dicionário chave-valor, para acompanhamento dos itens.
func add_to_dictionary():
	var key: String
	var value: InvItem
	for i in items.size():
		if items[i-1] == null:
			continue
		key = items[i-1].name
		value = items[i-1]
		items_map[key] = value

func get_item(name:String): 
	return items_map.get(name)
