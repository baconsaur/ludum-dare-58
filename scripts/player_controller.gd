extends Node2D

signal energy_change

enum State {
	IDLE,
	DESCENDING,
	ASCENDING,
	COOLDOWN,
}

@export var ascend_speed: Vector2 = Vector2(40.0, -30.0)
@export var descend_speed: Vector2 = Vector2(35.0, 30.0)
@export var hook_origin: Vector2 = Vector2.ZERO
@export var camera_offset: int = 40
@export var max_depth: int = 200
@export var cooldown_time: float = 2.0
@export var shake_cost: float = 3.0

var energy: float = 100.0
var state: State = State.IDLE
var fish_on_hook: bool = false

@onready var hook = $Hook
@onready var catches = $Hook/Catches
@onready var collection = $Collection
@onready var camera = $Hook/Camera2D
@onready var line: Line2D = $Line
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	hook.position = hook_origin
	camera.position.y = camera_offset
	
	energy = 100
	emit_signal("energy_change", energy)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("action"):
		take_action()
		return
	
	if fish_on_hook:
		return

	if Input.is_action_just_pressed("up") and state == State.DESCENDING:
		reel()
	if Input.is_action_just_pressed("down") and state == State.ASCENDING:
		hook.velocity = Vector2.ZERO
		camera.position.y = -camera_offset
		set_state(State.DESCENDING)

func _physics_process(delta: float) -> void:
	move_hook(delta)

func take_action():
	if state == State.COOLDOWN or energy <= 0:
		return
	elif state == State.IDLE:
		cast()
	elif fish_on_hook:
		shake()

func cast():
	if state != State.IDLE or energy <= 0:
		return
	set_state(State.DESCENDING)

func move_hook(delta):
	if state not in [State.DESCENDING, State.ASCENDING]:
		return
  
	var y_direction = Input.get_axis("up", "down")
	var speed = descend_speed
	if state == State.ASCENDING:
		if fish_on_hook:
			speed = ascend_speed / 2
		elif y_direction < 0:
			speed = ascend_speed + (ascend_speed * abs(y_direction) * 2)
		else:
			speed = ascend_speed
	#if state == State.DESCENDING and y_direction > 0:
		#speed = descend_speed + (descend_speed * y_direction * 2)

	var x_direction = Input.get_axis("left", "right")
	if x_direction:
		hook.velocity.x = x_direction * speed.x
	else: 
		hook.velocity.x = move_toward(hook.velocity.x, 0, speed.x * delta)

	hook.velocity.y = speed.y
	hook.move_and_slide()
	
	if hook.position.y <= hook_origin.y: 
		catch()
	elif hook.position.y >= max_depth:
		reel()
	elif state == State.ASCENDING and hook.velocity.y <= 0.01:
		hook.position.x = hook.position.move_toward(hook_origin, ascend_speed.x * delta).x

	line.set_point_position(1, hook.position)
	if state == State.DESCENDING:
		spend_energy(delta)

func spend_energy(delta):
	if energy <= 0:
		return

	energy -= delta
	emit_signal("energy_change", energy)
	
	if energy <= 0 and state == State.DESCENDING:
		set_state(State.ASCENDING)

func hook_item(item: Node2D):
	if item in catches.get_children():
		return

	if not item.is_connected("dropped", lost_item.bind(item)):
		item.connect("dropped", lost_item.bind(item), CONNECT_DEFERRED)

	item.call_deferred("hook", catches)
	if item.is_in_group("fish"):
		fish_on_hook = true
		reel()

func drop_item(item):
	if item not in catches.get_children():
		return
	item.drop()

func reel():
	if state != State.DESCENDING:
		return
	
	hook.velocity = Vector2.ZERO
	camera.position.y = -camera_offset
	cooldown(0.15, State.ASCENDING)
  
func shake():
	if state != State.ASCENDING:
		return
	animation_player.play("shake")
	spend_energy(shake_cost)
	for item in catches.get_children():
		item.shake()

func catch():
	camera.position.y = camera_offset
	hook.position = hook_origin
	hook.velocity = Vector2.ZERO
	fish_on_hook = false
	call_deferred('process_catches')

func lost_item(item: Node2D):
	item.disconnect("dropped", lost_item)
	
	if not fish_on_hook:
		return

	for child in catches.get_children():
		if child.is_in_group("fish"):
			return
	fish_on_hook = false

func cooldown(seconds, next_state: State=state):
	set_state(State.COOLDOWN)
	var timer = Timer.new()
	timer.connect("timeout", func(): set_state(next_state); timer.queue_free())
	timer.wait_time = seconds
	timer.one_shot = true
	add_child(timer)
	timer.start()

func process_catches():
	cooldown(0.25 * (catches.get_child_count() + 1), State.IDLE)
	
	for item in catches.get_children():
		if item.is_in_group("fish"):
			# TODO death or whatever
			item.queue_free()
		else:
			catches.remove_child(item)
			collection.add_child(item)
			item.global_position = collection.global_position

func set_state(new_state):
	# TODO exit/enter transitions
	state = new_state

func _on_catch_radius_body_entered(body: Node2D) -> void:
	if body.is_in_group("catchable"):
		hook_item(body)
