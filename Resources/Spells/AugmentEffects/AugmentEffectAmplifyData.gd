extends AugmentEffectData
class_name AmplifyEffect

@export var damage_mult: float
@export var mana_mult: float
@export var ap_mult: float


func apply(spell: SpellLib.ResolvedSpell) -> void:
	spell.base_damage = floor(spell.base_damage * damage_mult)
	#spell.base_mana = floor(spell.base_mana * mana_mult) placeholder for when mana is implemented
	#spell.base_ap = floor(spell.base_ap * ap_mult) placeholder
	
