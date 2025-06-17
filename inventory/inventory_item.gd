extends Resource
class_name InvItem

# Cada item de customização é um InvItem. Os nomes devem ser únicos, pois
# servem como identificadores no código.

@export var name: String = ""
@export var texture: Texture2D
@export var price: int
@export var unlock_level: int
@export var type: String
@export var style_box: StyleBox

# Apenas fundos devem ter StyleBox
