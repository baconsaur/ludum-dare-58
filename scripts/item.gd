extends RigidBody2D

@onready var original_parent = get_parent()

func hook(catch_zone):
	original_parent.remove_child(self)
	catch_zone.add_child(self)
	freeze = true
	global_position = catch_zone.global_position

func drop():
	get_parent().remove_child(self)
	original_parent.add_child(self)
	position = Vector2.ZERO
	freeze = false

func _on_body_entered(body: Node) -> void:
	print_debug(body.name)
	if body.name != "Hook":
		return
	var player: Node2D = body.get_parent()
	player.hook_item(self)
