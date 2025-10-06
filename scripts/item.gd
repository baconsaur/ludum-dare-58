extends RigidBody2D

signal dropped
signal touched_item

@export var value: int = 10
@export var drop_chance = 0.2
@export var drop_offset: Vector2 = Vector2(0, 10.0)
@export var throw_speed: float = 80.0

var hooked: bool = false
var can_catch: bool = true

@onready var original_parent = get_parent()
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var value_label: Label = $Value

func _ready() -> void:
	randomize()
	value_label.text = str(value)

func hook(catch_zone):
	if hooked or not can_catch:
		return
	
	animation_player.play("pickup")
	original_parent.remove_child(self)
	catch_zone.add_child(self)
	freeze = true
	hooked = true
	can_catch = false
	global_position = catch_zone.global_position

func shake():
	if randf_range(0, 1) < drop_chance:
		drop()

func throw():
	var random_angle = randf_range(0, 2 * PI)
	var throw_direction = Vector2.RIGHT.rotated(random_angle)
	var throw_vector = throw_direction * throw_speed
	
	apply_central_impulse(throw_vector)
	
	await get_tree().create_timer(1.0).timeout
	hooked = false
	can_catch = true

func drop():
	if not hooked:
		return

	var last_pos = global_position
	get_parent().remove_child(self)
	original_parent.add_child(self)
	global_position = last_pos + drop_offset
	
	freeze = false
	throw()
	emit_signal("dropped")

func remove():
	animation_player.play("lost")

func _on_chain_area_body_entered(body: Node2D) -> void:
	if not hooked:
		return

	if not body.is_in_group("collectible"):
		return
	
	emit_signal("touched_item", body)
	
