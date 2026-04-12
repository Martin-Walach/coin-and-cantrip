extends Node

class_name SpellCompiler

@onready
var action_lib = preload("uid://dk3eb6nmhvnv5").new()
var spell_lib = preload("uid://bdipnsc8kkwxm").new()
const spellwordtype = ActionLib.SPELL_WORD_TYPE
const SpellWord = ActionLib.SpellWord
const Spell = ActionLib.Spell
const Cantrip = ActionLib.Cantrip
const ResolvedSpell = SpellLib.ResolvedSpell
signal spells_resolved(resolved_spells: Array[ResolvedSpell])

func compile_spell(legal_words: Array) -> void:
	var spell = Spell.new()
	var current_cantrip: Cantrip = null
	var current_element: Cantrip.ElementWord = null
	var resolved_spells = Array()
	
	for cantrip_word in legal_words:
		match cantrip_word.get_word_type():
			spellwordtype.FORM:
				if current_cantrip != null and current_element != null:
					current_cantrip.add_element(current_element)
					current_element = null
				if current_cantrip != null:
					spell.add_cantrip(current_cantrip)
				current_cantrip = Cantrip.new(
				cantrip_word.expected_word,
				cantrip_word.word_distance
				)
			spellwordtype.ELEMENT:
				if current_cantrip != null and current_element != null:
					current_cantrip.add_element(current_element)
				current_element = Cantrip.ElementWord.new(
				cantrip_word.expected_word,
				cantrip_word.word_distance
				)
			spellwordtype.AUGMENT:
				if current_cantrip != null and current_element != null:
					current_element.add_augment(Cantrip.AugmentWord.new(cantrip_word.expected_word, cantrip_word.word_distance))
	
	if current_cantrip != null and current_element != null: 
		current_cantrip.add_element(current_element)
	if current_cantrip != null:
		spell.add_cantrip(current_cantrip)
	resolved_spells = resolve_spell(spell)
	spells_resolved.emit(resolved_spells)

func resolve_spell(spell: Spell) -> Array[ResolvedSpell]:
	var current_resolved_spells: Array[ResolvedSpell]
	for cantrip in spell.cantrips:
		match cantrip.form:
			"ray":
				current_resolved_spells.append(spell_lib.resolve_ray(cantrip))
				
	return current_resolved_spells
