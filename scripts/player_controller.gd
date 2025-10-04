extends Node2D
enum State {
	IDLE,
	DESCENDING,
	ASCENDING,
}

@export var ascend_speed: Vector2 = Vector2(50.0, -100.0)
@export var descend_speed: Vector2 = Vector2(50.0, 50.0)
@export var hook_origin: Vector2 = Vector2.ZERO

var energy: int = 100
var state: State = State.IDLE

@onready var hook = $Hook # TODO rename me pls

func _ready() -> void:
	hook.position = hook_origin

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("action"):
		take_action()

func _physics_process(delta: float) -> void:
	move_hook(delta)

func take_action():
	if state == State.IDLE:
		cast()
	elif state == State.DESCENDING:
		reel()

func cast():
	if state != State.IDLE:
		return
	set_state(State.DESCENDING)

func move_hook(delta):
	if state not in [State.DESCENDING, State.ASCENDING]:
		return

	var speed = descend_speed
	if state == State.ASCENDING:
		speed = ascend_speed

	var x_direction = Input.get_axis("left", "right")
	if x_direction:
		hook.velocity.x = x_direction * speed.x
	else:
		hook.velocity.x = move_toward(hook.velocity.x, 0, speed.x * delta)

	hook.velocity.y = speed.y
	hook.move_and_slide()
	
	if hook.position.y <= 0:
		hook.position = hook_origin
		set_state(State.IDLE)

func hook_item():
	if state != State.DESCENDING:
		return
	# TODO track hooked items
	set_state(State.ASCENDING)

func reel():
	if state != State.DESCENDING:
		return
	set_state(State.ASCENDING)

func set_state(new_state):
	# TODO exit/enter
	state = new_state
