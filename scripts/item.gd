extends RigidBody2D

signal dropped

@export var drop_chance = 0.2
@export var drop_offset: Vector2 = Vector2(0, 10.0)

var hooked: bool = false

@onready var original_parent = get_parent()

func _ready() -> void:
	randomize()

func hook(catch_zone):
	if hooked:
		return
	
	original_parent.remove_child(self)
	catch_zone.add_child(self)
	freeze = true
	hooked = true
	global_position = catch_zone.global_position

func shake():
	if randf_range(0, 1) < drop_chance:
		drop()

func drop():
	if not hooked:
		return
	get_parent().remove_child(self)
	original_parent.add_child(self)
	global_position = global_position + drop_offset

	hooked = false
	emit_signal("dropped")
	
	await get_tree().create_timer(1.0).timeout
	freeze = false
