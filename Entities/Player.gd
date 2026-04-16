extends Entity

class_name Player

var input_field: LineEdit = null

var player_equipment = Array() #Mock variable for the player
	
func _init(given_health: int, given_name: String, given_mana: int, given_speed: int, given_equipment: Array = []) -> void:
	super(given_health, given_name, given_mana, given_speed)
	player_equipment = given_equipment

func take_action(_allies: Array[Entity], _enemies: Array[Entity]):
	print("Players turn")
	input_field.editable = true
	input_field.grab_focus()
