extends Resource

class_name InvItem

@export var name: String = ""
@export var texture: Texture2D
@export var price: int
@export var unlock_level: int
@export var type: String

# Item should emit() "item_bought" when there is an attempt at buying it (clicking
# the button + item is available (as in, has been stocked and the player is the
# minimum level necessary to buy it).
