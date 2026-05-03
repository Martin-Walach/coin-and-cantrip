class_name ActionLib

const forms = {"ray":10, "cone":4, "shield":20}
const elements = {"fire":5, "water":2, "earth":4, "wind":3}
const augments = {"piercing":0.4, "amplified":1.2, "swift":0.7}

var actions = {"attack":true, "run":true, "item":true, "defend":true, "examine":true}

enum SPELL_WORD_TYPE {INIT, FORM, ELEMENT, AUGMENT, ILLEGAL}

func get_forms() -> Dictionary:
	return forms

func get_elements() -> Dictionary:
	return elements
	
func get_augments() -> Dictionary:
	return augments

class SpellWord:
	var expected_word: String
	var word_distance: int
	var spellwordtype: SPELL_WORD_TYPE
	func get_expected_word() -> String:
		return expected_word
	func get_word_distance() -> int:
		return word_distance
	func get_word_type() -> SPELL_WORD_TYPE:
		return spellwordtype
	func _init(word: String, distance: int, type: SPELL_WORD_TYPE) -> void:
		expected_word = word
		word_distance = distance
		spellwordtype = type

class Cantrip:
	var form: String
	var form_distance: int
	var elements: Array[ElementWord]
	
	func _init(form_word: String, form_dist: int) -> void:
		form = form_word
		form_distance = form_dist
		
	func add_element(element: ElementWord) -> void:
		elements.append(element)
		
	class ElementWord:
		var element_word: String
		var element_distance: int
		var augments: Array[AugmentWord] = []
		
		func _init(given_word: String, given_dist: int) -> void:
			element_word = given_word
			element_distance = given_dist
		
		func add_augment(augment_word: AugmentWord) -> void:
			augments.append(augment_word)
			
	class AugmentWord:
		var augment_word: String
		var augment_distance: int
		
		func _init(given_word: String, given_dist: int) -> void:
			augment_word = given_word
			augment_distance = given_dist

class Spell:
	var cantrips: Array[Cantrip] = []
	
	func add_cantrip(cantrip: Cantrip) -> void:
		if cantrip.form != null:
			cantrips.append(cantrip)
