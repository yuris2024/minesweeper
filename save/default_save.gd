extends Resource
class_name SaveData

@export var coins = 0
@export var experience = 0
@export var difficulty = 1
@export var records: Array[int] = [999,999,999]
@export var inventory = [] #Array[InvSlot]
@export var bg = "res://inventory/items/Backgrounds/bg_grey.tres"
@export var flag = "res://inventory/items/Flags/flag_red.tres"
@export var mine = "res://inventory/items/Mines/mine_red.tres"

func set_coins(x):
	coins = x

func set_experience(x):
	experience = x

func set_inventory(x):
	inventory = x

func set_appearance(x,y,z):
	bg = x
	flag = y
	mine = z

func set_bg(x):
	bg = x

func set_flag(x):
	flag = x
	
func set_mine(x):
	mine = x
