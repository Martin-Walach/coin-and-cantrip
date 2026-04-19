extends Node

class_name EncounterManager

var timeline: Dictionary = {}
var current_turn_entity: Entity = null
var to_be_destroyed: Array[Entity] = []
var allies: Array[Entity] = []
var enemies: Array[Entity] = []
var current_player_target: Entity

signal encounter_resolved()

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

func start_encounter() -> void:
	print("encouter start")
	for entity in allies + enemies:
		timeline[entity] = entity.entity_speed
	start_turn()
	

func get_next_entity() -> Entity:
	print("searching next entity")
	var next: Entity = null
	var lowest_time: int = 1000
	for entity in timeline.keys():
		if timeline[entity] < lowest_time:
			lowest_time = timeline[entity]
			next = entity
	return next

func start_turn() -> void:
	print("turn start")
	current_turn_entity = get_next_entity()
	debug_print()
	var elapsed = timeline[current_turn_entity]
	for entity in timeline.keys():
		timeline[entity] -= elapsed
	current_turn_entity.take_action(allies, enemies)
	if current_turn_entity is not Player:
		end_turn(current_turn_entity, 20)

func end_turn(current: Entity, ap_cost: int) -> void:
	print("turn end")
	timeline[current] = ap_cost * current.entity_speed #given that ap_cost is effectively a multiplyer
	for entity in to_be_destroyed:
		timeline.erase(entity)
		remove_child(entity)
	to_be_destroyed.clear()
	if check_encounter_end():
		encounter_resolved.emit()
		return
	start_turn()
	

func on_entity_destroyed(entity: Entity) -> void:
	print("entity destroyed called")
	to_be_destroyed.append(entity)
	if entity == current_player_target:
		current_player_target = null

func apply_spell_damage(resolved_spells: Array[SpellLib.ResolvedSpell]) -> void:
	print("apply damage called")
	if current_turn_entity is Player:
		current_turn_entity.input_field.editable = false
	if current_player_target == null:
		current_player_target = select_first_entity(enemies)
	for spell in resolved_spells:
		current_player_target.take_damage(spell.damage)
	end_turn(current_turn_entity, 20)

func select_first_entity(entities: Array[Entity]) -> Entity:
	print("fist entity called")
	for entity in entities:
		if entity.entity_health > 0:
			return entity
	return null

func check_encounter_end() -> bool:
	var living_allies = allies.filter(func(e: Entity): return e.entity_health > 0)
	var living_enemies = enemies.filter(func(e: Entity): return e.entity_health > 0)
	return living_allies.is_empty() or living_enemies.is_empty()

func debug_print() -> void:
	print("--- TURN: %s ---" % current_turn_entity.entity_name)
	for entity in timeline.keys():
		print("  %s | HP: %d | Time: %d" % [
			entity.entity_name, 
			entity.entity_health, 
			timeline[entity]
			])
