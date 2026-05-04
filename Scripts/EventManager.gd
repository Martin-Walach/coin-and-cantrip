extends Control

class_name EventManager

var spell_compiler: SpellCompiler
var input_field: ActionParser
var event_log: EventLogController
var encounter: EncounterManager

enum EVENT_STATE {NARRATIVE, ENCOUNTER, SHOP, RESOLVED}

var allies: Array[Entity] = []
var enemies: Array[Entity] = []
var current_state: EVENT_STATE = EVENT_STATE.ENCOUNTER

func _ready() -> void:
	spell_compiler = preload("res://Scripts/SpellCompiler.gd").new()
	event_log = $EventLog
	input_field = $InputField
	var player = Player.new(100, "Player", 50, 12, 5, [])
	player.input_field = input_field
	player.action_log.connect(event_log.on_entity_action)
	var goblin = MockEnemy.new(30, "Goblin", 0, 8, 5)
	goblin.action_log.connect(event_log.on_entity_action)
	allies.append(player)
	enemies.append(goblin)
	for entity in allies:
		print("  Ally: ", entity, " speed: ", entity.entity_speed)
	for entity in enemies:
		print("  Enemy: ", entity, " speed: ", entity.entity_speed)
	encounter = EncounterManager.new(allies, enemies)
	match current_state:
		EVENT_STATE.ENCOUNTER:
			add_child(encounter)
			encounter.encounter_resolved.connect(self.end_encounter)
			encounter.turn_status.connect(event_log.on_turn_status)
			encounter.start_encounter()
	

func end_encounter() -> void:
	encounter.queue_free()
	event_log.encounter_end()

func _on_input_field_spell_parsed(parsed_words: Array[ActionLib.SpellWord]) -> void:
	var compiled_spells: ActionLib.Spell = spell_compiler.compile_spell(parsed_words)
	var resolved_spells: Array[SpellLib.ResolvedSpell] = spell_compiler.resolve_spell(compiled_spells)
	event_log.on_spells_resolved(resolved_spells)
	encounter.apply_spell_damage(resolved_spells)
