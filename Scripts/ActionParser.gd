extends LineEdit

class_name ActionParser

signal spell_parsed(parsed_words: Array)
signal empty_input(_is_empty: bool)

@onready
var action_lib = preload("res://libs/ActionLib.gd").new()
const found_type = ActionLib.SpellWordType
const Spell_word = ActionLib.Spell_word

func _on_input_field_text_submitted(new_text: String) -> void:
	print(new_text)
	
	self.clear()
	
	var words = new_text.strip_edges().to_lower().split(" ", false)
	if words.is_empty():
		empty_input.emit(true)
		return
	
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
	spell_parsed.emit(legit_words_found)
		
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
	
