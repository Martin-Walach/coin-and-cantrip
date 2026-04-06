extends Node

class_name SpellCompiler

@onready
var action_lib = preload("res://libs/ActionLib.gd").new()
const found_type = ActionLib.SpellWordType
const Spell_word = ActionLib.Spell_word
signal spell_compiled(spell: Spell)

class Cantrip:
	var form: String = ""
	var form_distance: int = 64
	var elements: Array[Array] = []
	var augments: Array[Dictionary] = []
	
	func _init(form_word: String = "", form_dist: int = 64) -> void:
		form = form_word
		form_distance = form_dist
		
	func add_element(word: String, distance: int) -> void:
		elements.append({"word": word, "distance": distance})
		
	func add_augment(word: String, distance: int) -> void:
		augments.append({"word": word, "distance": distance})

class Spell:
	var cantrips: Array[Cantrip] = []
	
	func add_cantrip(cantrip: Cantrip) -> void:
		if cantrip.form != "":
			cantrips.append(cantrip)
	
func compile_spell(legal_words: Array) -> void:
	var spell = Spell.new()
	var current_cantrip: Cantrip = null
	
	for spell_word in legal_words:
		match spell_word.get_word_type():
			found_type.FORM:
				if current_cantrip != null:
					spell.add_cantrip(current_cantrip)
				current_cantrip = Cantrip.new(
					spell_word.expected_word,
					spell_word.word_distance
				)
			found_type.ELEMENT:
				if current_cantrip != null:
					current_cantrip.add_element(
					spell_word.expected_word,
					spell_word.word_distance
				)
			found_type.AUGMENT:
				if current_cantrip != null:
					current_cantrip.add_augment(
					spell_word.expected_word,
					spell_word.word_distance
				)
	if current_cantrip != null:
		spell.add_cantrip(current_cantrip)
	spell_compiled.emit(spell)

func resolve_spell(spell: Spell) -> void:
	for cantrip in spell:
		pass
		
		#I wouldn't want to clutter the scene tree with too many functions, so how about the compiler and resolver were in the same script and we just called the whole step as compilation? In that case, I would need to send and receive a signal within the same script and node. Is this a legit thing to do, or do people dislike this approach?
