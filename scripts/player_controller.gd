extends Node2D
enum State {
	IDLE,
	DESCENDING,
	ASCENDING,
}

@export var ascend_speed: Vector2 = Vector2(30.0, -35.0)
@export var descend_speed: Vector2 = Vector2(30.0, 30.0)
@export var hook_origin: Vector2 = Vector2.ZERO
@export var camera_offset: int = 40

var energy: int = 100
var state: State = State.IDLE

@onready var hook = $Hook
@onready var catches = $Hook/Catches
@onready var collection = $Collection
@onready var camera = $Hook/Camera2D

func _ready() -> void:
	hook.position = hook_origin
	camera.position.y = camera_offset

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
	
	if hook.position.y <= hook_origin.y:
		hook.position = hook_origin
		call_deferred('process_catches')
		set_state(State.IDLE)

func hook_item(item: Node2D):
	item.call_deferred("hook", catches)
	reel()

func reel():
	if state != State.DESCENDING:
		return
	
	camera.position.y = -camera_offset
	set_state(State.ASCENDING)

func shake():
	if state != State.ASCENDING:
		return

func process_catches():
	for catch in catches.get_children():
		if catch.is_in_group("fish"):
			# TODO death or whatever
			catch.queue_free()
		else:
			catches.remove_child(catch)
			collection.add_child(catch)
			catch.global_position = collection.global_position

func set_state(new_state):
	# TODO exit/enter transitions
	state = new_state
