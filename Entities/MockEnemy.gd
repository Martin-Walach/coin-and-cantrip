extends Entity

class_name MockEnemy

var defense: int = 5 #Mock variable for the enemy
var turn_ap_cost: int = 20

func _init(given_health: int, given_name: String, given_mana: int, given_speed: int, given_defense: int) -> void:
	super(given_health, given_name, given_mana, given_speed)
	defense = given_defense

func take_action(allies: Array[Entity], _enemies: Array[Entity]) -> int:
	print("enemies turn")
	if !allies.is_empty():
		allies.get(0).take_damage(10)
		action_log.emit(self.entity_name, 10, allies.get(0).entity_name)
	return turn_ap_cost
