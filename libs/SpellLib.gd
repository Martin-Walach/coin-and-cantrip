class_name SpellLib

var action_lib = preload("uid://dk3eb6nmhvnv5").new()
const Spell = ActionLib.Spell
const Cantrip = ActionLib.Cantrip

class ResolvedSpell:
	var base_damage: int
	var elemental_damage: int
	var accuracy: float
	
	func _init(given_base_damage: int, given_elemental_damage: int, given_accuracy: float) -> void:
		base_damage = given_base_damage
		elemental_damage = given_elemental_damage
		accuracy = given_accuracy

func resolve_ray(cantrip: Cantrip) -> ResolvedSpell:
	var form_accuracy: float = 1.0 - (float(cantrip.form_distance) / cantrip.form.length())
	var form_damage: float = action_lib.forms.get(cantrip.form) * form_accuracy
	var element_damage: float = 0
	var accuracy: float = form_accuracy * 100
	var temp_dmg: float = 0
	for element in cantrip.elements:
		var elem_accuracy: float = 1.0 - (float(element.element_distance) / element.element_word.length())
		temp_dmg = action_lib.elements.get(element.element_word) * elem_accuracy
		accuracy = (accuracy + elem_accuracy * 100) / 2.0
		for augment in element.augments:
			var aug_accuracy: float = 1.0 - (float(augment.augment_distance) / augment.augment_word.length())
			temp_dmg *= action_lib.augments.get(augment.augment_word) * aug_accuracy
			accuracy = (accuracy + aug_accuracy * 100) / 2.0
		element_damage += temp_dmg
		temp_dmg = 0
	print("%4.1f" % accuracy)
	print("%2.1f from form and %2.1f damage from element" % [form_damage, element_damage])
	return ResolvedSpell.new(ceili(form_damage),ceili(element_damage), accuracy)
