extends Node

class_name ActionLib

var forms = {"ray":true, "cone":true, "shield":true}
var elements = {"fire":true, "water":true, "earth":true, "wind":true}
var augments = {"piercing":true, "amplified":true, "swift":true}

var actions = {"attack":true, "run":true, "item":true, "defend":true, "examine":true}

func get_forms() -> Dictionary:
	return forms

func get_elements() -> Dictionary:
	return elements
	
func get_augments() -> Dictionary:
	return augments
