extends "uid://b8nvwj3crupua"

class_name Player

var player_equipment = Array() #Mock variable for the player
	
func _init(given_health: int, given_name: String, 
		   given_mana: int, given_speed: int,
		   given_equipment: Array = []) -> void:
	super(given_health, given_name, given_mana, given_speed)
	player_equipment = given_equipment
