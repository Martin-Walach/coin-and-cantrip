extends RichTextLabel


@onready
var input_field = get_node("../InputField")

var action_lib = preload("res://libs/ActionLib.gd").new()

enum found_type {INIT, FORM, ELEMENT, AUGMENT, ILLEGAL}

class Spell_word:
	var expected_word: String
	var word_distance: int
	var word_type: found_type
	func get_expected_word() -> String:
		return expected_word
	func get_word_distance() -> int:
		return word_distance
	func get_word_type() -> found_type:
		return word_type
	func _init(word: String, distance: int, type: found_type) -> void:
		expected_word = word
		word_distance = distance
		word_type = type

func _on_input_field_text_submitted(new_text: String) -> void:
	print(new_text)
	
	input_field.clear()
	
	var words = new_text.strip_edges().to_lower().split(" ", false)
	if words.is_empty():
		self.append_text("no text found")
		return
		
	self.newline()
	
	var current_element_count = 0
	var found_word_type = found_type.INIT
	var legit_words_found = Array()
	var found_word = Spell_word.new("", 64, found_type.INIT)
	for word in words:
		found_word = word_parse(word, found_word_type)
		if found_word.get_word_type() == found_type.FORM:
			current_element_count = 0
		if found_word.get_word_type() == found_type.ELEMENT:
			if current_element_count >= 2:
				found_word_type = found_type.ILLEGAL
				current_element_count = 0
				continue
			current_element_count += 1
		legit_words_found.append(found_word)
		found_word_type = found_word.get_word_type()
	for i in legit_words_found:
		print(i.expected_word)
		
	#send legit_words_found to Spell Logic Compiler which is not yet implemented 
		
func word_parse(word: String, word_type: found_type) -> Spell_word:
	match word_type:
		found_type.INIT, found_type.ILLEGAL:
			return find_best_match(word, action_lib.get_forms(), found_type.FORM)
		found_type.FORM:
			return find_best_match(word, action_lib.get_elements(), found_type.ELEMENT)
		found_type.ELEMENT, found_type.AUGMENT:
			var augment_spell_word = find_best_match(word, action_lib.get_augments(), found_type.AUGMENT)
			var element_spell_word = find_best_match(word, action_lib.get_elements(), found_type.ELEMENT)
			var form_spell_word = find_best_match(word, action_lib.get_forms(), found_type.FORM)
			if form_spell_word.word_distance <= element_spell_word.word_distance and form_spell_word.word_distance <= augment_spell_word.word_distance:
				return form_spell_word
			elif element_spell_word.word_distance <= form_spell_word.word_distance and element_spell_word.word_distance <= augment_spell_word.word_distance:
				return element_spell_word
			else:
				return augment_spell_word
	return Spell_word.new("", 64, found_type.INIT)
	
func find_best_match(word: String, dictionary: Dictionary, word_type: found_type) -> Spell_word:
	var closest_distance = 64
	var closest_word = ""
	
	for dict_word in dictionary.keys():
		var distance = Levenshtein.distance(word, dict_word)
		if distance == 0:
			return Spell_word.new(dict_word, 0, word_type)
		if distance > 3 :
			continue
		if distance < closest_distance:
			closest_distance = distance
			closest_word = dict_word
	return Spell_word.new(closest_word, closest_distance, word_type)
	
