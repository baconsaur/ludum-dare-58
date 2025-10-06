extends CharacterBody2D

signal dropped
signal touched_item

enum State {
	IDLE,
	ALERT,
	HOOKED,
	ATTACK,
}

@export var idle_speed: float = 15.0
@export var alert_speed: float = 25.0
@export var patrol_range: float = 50.0
@export var max_alert_distance: float = 50.0
@export var max_stamina: int = 3
@export var drop_offset: Vector2 = Vector2(0, 25.0)
@export var max_alert_time: float = 3.0
@export var max_height: float = 25.0

var state: State = State.IDLE
var origin: Vector2 = Vector2.ZERO
var x_direction: int = 1
var target: Node2D
var stamina: int = max_stamina
var can_catch: bool = true

@onready var parent: Node2D = get_parent()
@onready var body_collider: CollisionShape2D = $CollisionShape2D
@onready var detect_collider: CollisionShape2D = $DetectionZone/CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	origin = position

func _physics_process(delta: float) -> void:
	move(delta)
	if velocity.x < 0:
		sprite.flip_h = false
	elif velocity.x > 0:
		sprite.flip_h = true

func move(delta):
	if state == State.ALERT:
		pursue(delta)
		return

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
		sprite.flip_h = not sprite.flip_h

func pursue(delta):
	if state != State.ALERT:
		return
	elif not target:
		set_state(State.IDLE)
		return

	global_position = global_position.move_toward(target.global_position, alert_speed * delta)
	if global_position.distance_to(target.global_position) > max_alert_distance:
		set_state(State.IDLE)
	
	move_and_slide()

func alert():
	if state != State.IDLE:
		return
	
	if not target:
		set_state(State.IDLE)
		return
	
	animation_player.play("alert")
	var timer = Timer.new()
	timer.connect("timeout", func(): timer.queue_free(); if state == State.ALERT: set_state(State.IDLE))
	timer.wait_time = max_alert_time
	timer.one_shot = true
	add_child(timer)
	timer.start()
	set_state(State.ALERT)

func hook(catch_zone):
	velocity = Vector2.ZERO
	can_catch = false
	
	body_collider.set_deferred("disabled", true)
	detect_collider.set_deferred("disabled", true)
	
	parent.remove_child(self)
	catch_zone.add_child(self)
	global_position.x = catch_zone.global_position.x
	if state not in [State.IDLE, State.ALERT]:
		return
	
	set_state(State.HOOKED)

func retreat():
	target = null
	global_position += drop_offset
	set_state(State.IDLE)

func shake():
	stamina -= 1
	if stamina <= 0:
		drop()

func drop():
	if state != State.HOOKED:
		return
	
	animation_player.stop()
	
	target = null
	stamina = max_stamina
	set_state(State.IDLE)
	
	var drop_position = global_position + drop_offset
	get_parent().remove_child(self)
	parent.add_child(self)
	global_position = drop_position
	
	emit_signal("dropped")
	
	await get_tree().create_timer(1.0).timeout
	body_collider.set_deferred("disabled", false)
	detect_collider.set_deferred("disabled", false)
	can_catch = true

func collect():
	print_debug("oh no")

func attack():
	set_state(State.ATTACK)

func defeat():
	print_debug("yay")
	queue_free()

func is_alert():
	return state == State.ALERT

func is_hooked():
	return state == State.HOOKED

func set_state(new_state):
	# TODO exit/enter
	state = new_state

func _on_detection_range_entered(body: Node2D) -> void:
	if body.name != "Hook":
		return
	target = body
	alert()
