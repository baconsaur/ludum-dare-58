extends CharacterBody2D
enum State {
	IDLE,
	ALERT,
	HOOKED,
}

@export var idle_speed: float = 30.0
@export var patrol_range: float = 50.0

var state: State = State.IDLE
var origin: Vector2 = Vector2.ZERO
var x_direction: int = 1

func _ready() -> void:
	origin = position

func _physics_process(delta: float) -> void:
	move(delta)

func move(_delta):
	if state != State.IDLE:
		return
	
	if position.x > origin.x + patrol_range:
		x_direction = -1
	elif position.x < origin.x - patrol_range:
		x_direction = 1

	velocity.x = x_direction * idle_speed
	var collided = move_and_slide()
	if collided:
		x_direction *= -1

func alert():
	if state != State.IDLE:
		return
	set_state(State.ALERT)

func hook(catch_zone):
	get_parent().remove_child(self)
	catch_zone.add_child(self)
	global_position = catch_zone.global_position
	if state not in [State.IDLE, State.ALERT]:
		return
	set_state(State.HOOKED)

func attack():
	pass

func defeat():
	pass

func set_state(new_state):
	# TODO exit/enter
	state = new_state

func _on_detection_range_entered(body: Node2D) -> void:
	if body.name != "Hook":
		return
	var player: Node2D = body.get_parent()
	player.hook_item(self)
	set_state(State.HOOKED)
