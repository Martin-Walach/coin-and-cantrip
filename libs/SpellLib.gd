class_name SpellLib

var action_lib = preload("uid://dk3eb6nmhvnv5").new()
const Spell = ActionLib.Spell
const Cantrip = ActionLib.Cantrip

class ResolvedSpell:
	var damage: int
	
	func _init(given_damage: int) -> void:
		damage = given_damage

func resolve_ray(cantrip: Cantrip) -> ResolvedSpell:
	var final_damage: float = action_lib.forms.get(cantrip.form)
	var element_damage: float = 0
	for element in cantrip.elements:
		element_damage += action_lib.elements.get(element.element_word)
		for augment in element.augments:
			element_damage *= action_lib.augments.get(augment.augment_word)
		final_damage += element_damage
		element_damage = 0
	print(int(ceil(final_damage)))
	return ResolvedSpell.new(int(ceil(final_damage)))
