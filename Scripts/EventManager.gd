extends Control

class_name EventManager

enum EVENT_STATE {NARRATIVE, ENCOUNTER, SHOP, RESOLVED}

func event_start(allies: Array[Entity], enemies: Array[Entity], state: EVENT_STATE) -> void:
	match state:
		EVENT_STATE.ENCOUNTER:
			add_child(EncounterManager.new(allies, enemies))
	
