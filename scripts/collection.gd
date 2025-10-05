extends Node2D

@export var num_cols: int = 3
@export var sprite_size: int = 8

func _on_child_order_changed() -> void:
	var row: int = 0
	var col: int = 0
	for item in get_children():
		item.position.x = row * sprite_size
		item.position.y = -col * sprite_size
		
		row += 1
		if row >= num_cols:
			row = 0
			col += 1
