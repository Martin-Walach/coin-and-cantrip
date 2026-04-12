extends LineEdit

class_name ActionParser

signal spell_parsed(parsed_words: Array[SpellWord])
signal empty_input(_is_empty: bool)

@onready
var action_lib = preload("uid://dk3eb6nmhvnv5").new()
const spellwordtype = ActionLib.SPELL_WORD_TYPE
const SpellWord = ActionLib.SpellWord

func _on_input_field_text_submitted(new_text: String) -> void:
	print(new_text)
	
	self.clear()
	
	var words = new_text.strip_edges().to_lower().split(" ", false)
	if words.is_empty():
		empty_input.emit(true)
		return
	
	var current_element_count = 0
	var found_word_type = spellwordtype.INIT
	var legit_words_found = Array()
	var found_word = SpellWord.new("", 64, spellwordtype.INIT)
	for word in words:
		found_word = word_parse(word, found_word_type)
		if found_word.get_word_type() == spellwordtype.FORM:
			current_element_count = 0
		if found_word.get_word_type() == spellwordtype.ELEMENT:
			if current_element_count >= 2:
				found_word_type = spellwordtype.ILLEGAL
				current_element_count = 0
				continue
			current_element_count += 1
		legit_words_found.append(found_word)
		found_word_type = found_word.get_word_type()
	for i in legit_words_found:
		print(i.expected_word)
	spell_parsed.emit(legit_words_found)
		
func word_parse(word: String, word_type: ActionLib.SPELL_WORD_TYPE) -> SpellWord:
	match word_type:
		spellwordtype.INIT, spellwordtype.ILLEGAL:
			return find_best_match(word, action_lib.get_forms(), spellwordtype.FORM)
		spellwordtype.FORM:
			return find_best_match(word, action_lib.get_elements(), spellwordtype.ELEMENT)
		spellwordtype.ELEMENT, spellwordtype.AUGMENT:
			var augment_spell_word = find_best_match(word, action_lib.get_augments(), spellwordtype.AUGMENT)
			var element_spell_word = find_best_match(word, action_lib.get_elements(), spellwordtype.ELEMENT)
			var form_spell_word = find_best_match(word, action_lib.get_forms(), spellwordtype.FORM)
			if form_spell_word.word_distance <= element_spell_word.word_distance and form_spell_word.word_distance <= augment_spell_word.word_distance:
				return form_spell_word
			elif element_spell_word.word_distance <= form_spell_word.word_distance and element_spell_word.word_distance <= augment_spell_word.word_distance:
				return element_spell_word
			else:
				return augment_spell_word
	return SpellWord.new("", 64, spellwordtype.INIT)
	
func find_best_match(word: String, dictionary: Dictionary, word_type: ActionLib.SPELL_WORD_TYPE) -> SpellWord:
	var closest_distance = 64
	var closest_word = ""
	
	for dict_word in dictionary.keys():
		var distance = Levenshtein.distance(word, dict_word)
		if distance == 0:
			return SpellWord.new(dict_word, 0, word_type)
		if distance > 3 :
			continue
		if distance < closest_distance:
			closest_distance = distance
			closest_word = dict_word
	return SpellWord.new(closest_word, closest_distance, word_type)
	
