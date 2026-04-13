extends Node

class_name Entity

var entity_health: int
var entity_name: String
var entity_mana: int

func _init(given_health: int, given_name: String, given_mana: int) -> void:
	entity_health = given_health
	entity_name = given_name
	entity_mana = given_mana

func take_damage(damage: int) -> void:
	self.entity_health -= damage
