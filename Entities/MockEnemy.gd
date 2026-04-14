extends "uid://b8nvwj3crupua"

class_name MockEnemy

var defense: int = 5 #Mock variable for the enemy

func _init(given_health: int, given_name: String, 
		   given_mana: int, given_speed: int,
		   given_defense: int) -> void:
	super(given_health, given_name, given_mana, given_speed)
	defense = given_defense
