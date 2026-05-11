extends Resource
class_name FormData

@export var form_name: String
@export var base_power: int
@export var mana_cost: int
@export var ap_cost: int
@export var target_type: TARGET_TYPES

enum TARGET_TYPES {SINGLE, CONE, SELF, ALL}
