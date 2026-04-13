extends "uid://b8nvwj3crupua"

class_name Player

var player_equipment = Array() #Mock variable for the player
	
func _init(given_equipment: Array) -> void:
	player_equipment = given_equipment
