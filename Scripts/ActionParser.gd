extends LineEdit

class_name ActionParser

## connected to [method EventManager._on_input_field_spell_parsed] via scene editor
signal spell_parsed(parsed_words: Array[SpellWord])
## connected to [method EventLogController._on_input_field_empty_input] via scene editor
signal empty_input(_is_empty: bool)

const spellwordtype = ActionLib.SPELL_WORD_TYPE
const SpellWord = ActionLib.SpellWord

## method called upon receiving input from the player.[br]
## Signal [signal LineEdit.text_submitted] emitted by [LineEdit] ([b]InputField[/b]) [br][br]
##
## Splits player input into lowercase words and if input is empty, emits [signal ActionParser.empty_input] to [RichTextLabel] [b]EventLog[/b].[br]
## Validates the syntax of player input and breaks the spell with [member SPELL_WORD_TYPE.ILLEGAL] if the syntax is invalid.[br]
## - Checks that the amount of elements per form does not exceed 2.[br]
## [br]
## Once all the words are encapsulated into an [Array] of [ActionLib.SpellWord]s, they are then emitted with
## [signal ActionParser.spell_parsed] to [method EventManager._on_input_field_spell_parsed]
func _on_input_field_text_submitted(new_text: String) -> void:
	print(new_text)
	
	self.clear()
	
	var words = new_text.strip_edges().to_lower().split(" ", false)
	if words.is_empty():
		empty_input.emit(true)
		return
	
	var current_element_count = 0
	var found_word_type = spellwordtype.INIT
	var legit_words_found: Array[SpellWord] = []
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
		
## State machine looking for best match of user's input [String] [param word]
## based on [enum ActionLib.SPELL_WORD_TYPE] and returns new [ActionLib.SpellWord].[br][br]
## Otherwise returns a new [ActionLib.SpellWord] of [b]null[/b] [String], distance of [b]64[/b]
## and [member ActionLib.SPELL_WORD_TYPE.INIT][br][br]
##
## [member SPELL_WORD_TYPE.INIT] is the initial value.[br]
## -> looking for [member SPELL_WORD_TYPE.FORM][br]
## [member SPELL_WORD_TYPE.FORM] where last word type was a form.[br]
## -> looking for [member SPELL_WORD_TYPE.ELEMENT][br]
## [member SPELL_WORD_TYPE.ELEMENT] where last word type was an element.[br]
## -> looking for [member SPELL_WORD_TYPE.FORM], [member SPELL_WORD_TYPE.ELEMENT] or [member SPELL_WORD_TYPE.AUGMENT]
func word_parse(word: String, word_type: ActionLib.SPELL_WORD_TYPE) -> SpellWord:
	match word_type:
		spellwordtype.INIT, spellwordtype.ILLEGAL:
			return find_best_match(word, ActionLib.forms, spellwordtype.FORM)
		spellwordtype.FORM:
			return find_best_match(word, ActionLib.elements, spellwordtype.ELEMENT)
		spellwordtype.ELEMENT, spellwordtype.AUGMENT:
			var augment_spell_word = find_best_match(word, ActionLib.augments, spellwordtype.AUGMENT)
			var element_spell_word = find_best_match(word, ActionLib.elements, spellwordtype.ELEMENT)
			var form_spell_word = find_best_match(word, ActionLib.forms, spellwordtype.FORM)
			if form_spell_word.word_distance <= element_spell_word.word_distance and form_spell_word.word_distance <= augment_spell_word.word_distance:
				return form_spell_word
			elif element_spell_word.word_distance <= form_spell_word.word_distance and element_spell_word.word_distance <= augment_spell_word.word_distance:
				return element_spell_word
			else:
				return augment_spell_word
	return SpellWord.new("", 64, spellwordtype.INIT)
	
## Looks for an expected type of word [param word_type] from [enum ActionLib.SPELL_WORD_TYPE] in a
## given [Dictionary] of words [param dictionary] and returns a [String] of the best match based on
## levenshtein distance [param word].
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
	
