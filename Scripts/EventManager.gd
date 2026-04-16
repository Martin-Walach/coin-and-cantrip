extends Control

class_name EventManager

var spell_compiler
var input_field

enum EVENT_STATE {NARRATIVE, ENCOUNTER, SHOP, RESOLVED}

var allies: Array[Entity] = []
var enemies: Array[Entity] = []
var current_state: EVENT_STATE = EVENT_STATE.ENCOUNTER

func _ready() -> void:
	spell_compiler = $SpellCompiler
	input_field = $InputField
	var player = Player.new(100, "Player", 50, 12, [])
	player.input_field = input_field
	var goblin = MockEnemy.new(30, "Goblin", 0, 8, 5)
	allies.append(player)
	enemies.append(goblin)
	for entity in allies:
		print("  Ally: ", entity, " speed: ", entity.entity_speed)
	for entity in enemies:
		print("  Enemy: ", entity, " speed: ", entity.entity_speed)
	var encouter = EncounterManager.new(allies, enemies)
	match current_state:
		EVENT_STATE.ENCOUNTER:
			add_child(encouter)
			spell_compiler.spells_resolved.connect(encouter.apply_spell_damage)
			encouter.encounter_resolved.connect(self.end_encounter)
			encouter.start_encounter()
	

func end_encounter(encounter: EncounterManager) -> void:
	spell_compiler.spells_resolved.disconnect(encounter.apply_spell_damage)
	encounter.queue_free()
