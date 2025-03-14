extends ColorRect

signal item_bought

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Item should emit() "item_bought" when there is an attempt at buying it (clicking
# the button + item is available (as in, has been stocked and the player is the
# minimum level necessary to buy it).

# Still not sure how to incorporate the resources we've created (shopinv.tres, flag_blue.tres etc).
# Or if we need to at all.
# We shall figure that out.

# 
