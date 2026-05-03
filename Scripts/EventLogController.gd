extends RichTextLabel

class_name EventLogController

const ResolvedSpell = SpellLib.ResolvedSpell

func on_spells_resolved(resolved_spells: Array[ResolvedSpell]) -> void:
	var final_string: String = ""
	for spell in resolved_spells:
		final_string = "The Player deals {0} damage\n".format([spell.base_damage + spell.elemental_damage])
		self.append_text(final_string)
		self.newline()

func on_enemy_action(given_name: String, damage: int, target: String) -> void:
	self.append_text("{0} deals {1} damage to {2}\n".format([given_name, str(damage), target]))
	self.newline()

func on_turn_status(given_status_message: String) -> void:
	self.append_text(given_status_message)
	self.newline()

func _on_input_field_empty_input(_is_empty: bool) -> void:
	self.append_text("no input received")
	self.newline()

func encounter_end() -> void:
	self.append_text("END")
	self.newline()
