extends RefCounted

class_name SpellCompiler

var spell_lib = preload("uid://bdipnsc8kkwxm").new()
const spellwordtype = ActionLib.SPELL_WORD_TYPE
const SpellWord = ActionLib.SpellWord
const Spell = ActionLib.Spell
const Cantrip = ActionLib.Cantrip
const ResolvedSpell = SpellLib.ResolvedSpell

## Takes an [Array] of [ActionLib.SpellWord] ([param legal_words]) from [ActionParser].[br]
## Depending on [enum ActionLib.SPELL_WORD_TYPE] of each [ActionLib.SpellWord] it aseembles [ActionLib.Cantrip]s
## based on syntax and adds them to an [Array] of [ActionLib.Cantrip]s known as a [ActionLib.Spell]
func compile_spell(legal_words: Array[SpellWord]) -> Spell:
	var spell = Spell.new()
	var current_cantrip: Cantrip = null
	var current_element: Cantrip.ElementWord = null
	
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
	return spell

## Takes a compiled [ActionLib.Spell] and begins resolving the effects of each [ActionLib.Cantrip]
## based on:[br][member ActionLib.Cantrip.form],[br][member ActionLib.Cantrip.elements] and[br][member ActionLib.Cantrip.elemnts.augments]
## 
func resolve_spell(spell: Spell) -> Array[ResolvedSpell]:
	var current_resolved_cantrips: Array[ResolvedSpell]
	for cantrip in spell.cantrips:
		match cantrip.form:
			"ray":
				current_resolved_cantrips.append(spell_lib.resolve_ray(cantrip))
				
	return current_resolved_cantrips
