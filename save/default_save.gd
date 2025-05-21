extends Resource
class_name SaveData

@export var coins = 0
@export var experience = 0
@export var difficulty = 1
@export var records: Array[int] = [999,999,999]
@export var inventory: Array[InvItem]
@export var bg_name = 'bg_grey'
@export var flag_name = 'flag_red'
@export var mine_name = 'mine_red'
@export var bg = "res://inventory/items/Backgrounds/" + bg_name + ".tres" 
@export var flag = "res://inventory/items/Flags/" + flag_name + ".tres"
@export var mine = "res://inventory/items/Mines/" + mine_name + ".tres"
