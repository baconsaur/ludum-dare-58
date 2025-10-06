extends Button

signal success
signal fail

func _ready() -> void:
	get_tree().paused = true

func init_timer(seconds=1.0):
	var timer = Timer.new()
	timer.connect("timeout", end)
	timer.wait_time = seconds
	timer.one_shot = true
	add_child(timer)
	timer.start()

func end():
	emit_signal("fail")
	get_tree().paused = false
	queue_free()

func _on_pressed() -> void:
	emit_signal("success")
	get_tree().paused = false
	queue_free()
