extends Node

class_name ActionLib

var forms = {"ray":true, "cone":true, "shield":true}
var elements = {"fire":true, "water":true, "earth":true, "wind":true}
var augments = {"piercing":true, "amplified":true, "swift":true}

var actions = {"attack":true, "run":true, "item":true, "defend":true, "examine":true}

enum SpellWordType {INIT, FORM, ELEMENT, AUGMENT, ILLEGAL}

func get_forms() -> Dictionary:
	return forms

func get_elements() -> Dictionary:
	return elements
	
func get_augments() -> Dictionary:
	return augments

class Spell_word:
	var expected_word: String
	var word_distance: int
	var word_type: SpellWordType
	func get_expected_word() -> String:
		return expected_word
	func get_word_distance() -> int:
		return word_distance
	func get_word_type() -> SpellWordType:
		return word_type
	func _init(word: String, distance: int, type: SpellWordType) -> void:
		expected_word = word
		word_distance = distance
		word_type = type
