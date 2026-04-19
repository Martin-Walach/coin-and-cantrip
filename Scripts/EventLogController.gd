extends RichTextLabel

class_name EventLogController

const ResolvedSpell = SpellLib.ResolvedSpell

func on_spells_resolved(resolved_spells: Array[ResolvedSpell]) -> void:
	var final_string: String = ""
	for spell in resolved_spells:
		print(spell.damage)
		final_string = "The Player deals {0} damage".format([spell.damage])
		self.append_text(final_string)
		self.newline()


func _on_input_field_empty_input(_is_empty: bool) -> void:
	self.append_text("no input received")
	self.newline()

func encounter_end() -> void:
	self.append_text("END")
	self.newline()
