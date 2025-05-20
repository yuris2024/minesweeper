extends Resource

class_name Inv

@export var items: Array[InvItem]

var items_map = {}

func add_to_dictionary():
	# Dicionário chave-valor, para acompanhamento dos itens.
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
	
