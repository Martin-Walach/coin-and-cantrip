extends Node

class_name EncounterManager

var timeline: Dictionary = {}
var current_turn_entity: Entity = null
var encounter_resolved: bool = false
var to_be_destroyed: Array[Entity] = Array()
var allies: Array[Entity] = []
var enemies: Array[Entity] = []

func _init(given_allies: Array[Entity], given_enemies: Array[Entity]) -> void:
	allies = given_allies
	enemies = given_enemies

func _ready() -> void:
	for entity in allies:
		add_child(entity)
		entity.entity_destroyed.connect(on_entity_destroyed)
	for entity in enemies:
		add_child(entity)
		entity.entity_destroyed.connect(on_entity_destroyed)
	start_encounter()
	

func start_encounter() -> void:
	for entity in allies + enemies:
		timeline[entity] = entity.entity_speed
	start_turn()
	

func get_next_entity() -> Entity:
	var next: Entity = null
	var lowest_time: int = 1000
	for entity in timeline.keys():
		if timeline[entity] < lowest_time:
			lowest_time = timeline[entity]
			next = entity
	return next

func start_turn() -> void:
	current_turn_entity = get_next_entity()
	var elapsed = timeline[current_turn_entity]
	for entity in timeline.keys():
		timeline[entity] -= elapsed

func end_turn(current: Entity, ap_cost: int) -> void:
	timeline[current] = ap_cost * current.entity_speed #given that ap_cost is effectively a multiplyer
	for entity in to_be_destroyed:
		timeline.erase(entity)
		remove_child(entity)
	to_be_destroyed.clear()

func on_entity_destroyed(entity: Entity) -> void:
	to_be_destroyed.append(entity)
