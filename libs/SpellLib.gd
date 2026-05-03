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
	var form_damage: float = action_lib.forms.get(cantrip.form) / (cantrip.form_distance + 1)
	var element_damage: float = 0
	var accuracy: float = (100 / (cantrip.form_distance + 1.0))
	var temp_dmg: float = 0
	for element in cantrip.elements:
		temp_dmg += action_lib.elements.get(element.element_word) / (element.element_distance + 1)
		accuracy = (accuracy + (100 / (element.element_distance + 1.0))) / 2
		for augment in element.augments:
			temp_dmg *= action_lib.augments.get(augment.augment_word)
			accuracy = (accuracy + (100 / (augment.augment_distance + 1.0))) / 2
		element_damage += temp_dmg
		temp_dmg = 0
	print("%4.1f" % accuracy)
	print("%f from form and %f damage from element" % [form_damage, element_damage])
	return ResolvedSpell.new(ceili(form_damage),ceili(element_damage), accuracy)
