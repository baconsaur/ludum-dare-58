extends CharacterBody2D

signal dropped

enum State {
	IDLE,
	ALERT,
	HOOKED,
}

@export var idle_speed: float = 15.0
@export var alert_speed: float = 30.0
@export var patrol_range: float = 50.0
@export var max_alert_distance: float = 40.0
@export var max_stamina: int = 3
@export var drop_offset: Vector2 = Vector2(0, 10.0)

var state: State = State.IDLE
var origin: Vector2 = Vector2.ZERO
var x_direction: int = 1
var target: Node2D
var stamina: int = max_stamina

@onready var parent: Node2D = get_parent()
@onready var body_collider: CollisionShape2D = $CollisionShape2D
@onready var detect_collider: CollisionShape2D = $DetectionZone/CollisionShape2D

func _ready() -> void:
	origin = position

func _physics_process(delta: float) -> void:
	move(delta)

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

func pursue(delta):
	if state != State.ALERT:
		return
	elif not target:
		set_state(State.IDLE)

	global_position = global_position.move_toward(target.global_position, alert_speed * delta)
	if global_position.distance_to(target.global_position) > max_alert_distance:
		set_state(State.IDLE)

func alert():
	if state != State.IDLE or not target:
		return
	set_state(State.ALERT)

func hook(catch_zone):
	body_collider.set_deferred("disabled", true)
	detect_collider.set_deferred("disabled", true)
	
	parent.remove_child(self)
	catch_zone.add_child(self)
	global_position = catch_zone.global_position
	if state not in [State.IDLE, State.ALERT]:
		return
	set_state(State.HOOKED)

func shake():
	stamina -= 1
	if stamina <= 0:
		drop()

func drop():
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
	target = body
	alert()
