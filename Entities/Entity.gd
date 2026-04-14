extends Node

class_name Entity

var entity_health: int
var entity_name: String
var entity_mana: int
var entity_speed: int

signal entity_destroyed(entity: Entity)

func _init(given_health: int, given_name: String, given_mana: int, given_speed: int) -> void:
	entity_health = given_health
	entity_name = given_name
	entity_mana = given_mana
	entity_speed = given_speed

func take_damage(damage: int) -> void:
	if entity_health <= 0:
		return
	entity_health -= damage
	if entity_health <= 0:
		entity_destroyed.emit(self)
