extends Node2D

@export var room_cost: int = 15
@export var food_cost: int = 5
@export var level_scenes: Array[PackedScene]
@export var qte_scene: PackedScene
@export var qte_time: float = 0.8

var day: int = 1
var balance: int = 0
var meals_skipped: int = 0
var current_level: Node2D
var items_left: int = 0
var level: int = 0

@onready var player = $Player
@onready var hud = $HUD
@onready var energy_bar = $HUD/MarginContainer/EnergyBar
@onready var hud_container = $HUD/MarginContainer
@onready var game_over_modal = $HUD/GameOver
@onready var level_end_modal = $HUD/LevelEnd
@onready var intro_modal = $HUD/Intro

func _ready() -> void:
	load_level(level_scenes[0])
	
	get_tree().paused = true
	intro_modal.visible = true
	
	game_over_modal.visible = false
	level_end_modal.visible = false
	
	player.connect("energy_change", update_energy)
	player.connect("died", game_over)
	player.connect("day_end", level_complete)
	player.connect("got_items", update_items_left)
	#player.connect("danger", repel_fish)
	
	energy_bar.max_value = player.max_energy

func load_level(new_level):
	if not new_level:
		return
	
	if current_level != null:
		current_level.queue_free()
		current_level = null

	current_level = new_level.instantiate()
	add_child(current_level)
	
	items_left = current_level.find_children("Item*").size()

#func repel_fish(fish):
	#var qte = qte_scene.instantiate()
	#hud_container.add_child(qte)
	#qte.init_timer(qte_time)
	#qte.connect("success", player.throw.bind(fish))
	#qte.connect("fail", fish.attack)

func update_items_left(change):
	items_left -= change
	
	if items_left <= 0:
		level_complete(player.get_catch_value())

func update_energy(energy):
	energy_bar.value = energy

func game_over(reason="Skill issue"):
	get_tree().paused = true
	
	game_over_modal.set_content(
		reason + "[br][br]You survived the wasteland for [color=\"yellow\"]"
		+ str(day) + "[/color] " + ("day" if day == 1 else "days")
	)
	game_over_modal.visible = true
	level_end_modal.visible = false

func level_complete(catch_value):
	var actual_food_cost = food_cost
	var comment = "You feel rested and recharged in the morning."
	player.max_energy += 10
	if not day % 2:
		comment += "[br]You got a longer fishing line."
	player.max_depth += 50
	room_cost += 1
	food_cost += 1
	
	if balance + catch_value < room_cost:
		game_over("You couldn't afford a room. You were eaten by a mutant.")
		return
	elif balance + catch_value < room_cost + food_cost:
		actual_food_cost = 0
		meals_skipped += 1
		if meals_skipped >= 3:
			game_over("After " + str(meals_skipped) + " days without eating, you starved to death.")
			return
		comment = "You slept well, but couldn't afford food. Your energy is low today."
	else:
		meals_skipped = 0

	level_end_modal.set_title("Day " + str(day))
	
	var final_balance = balance + catch_value - room_cost - actual_food_cost
	level_end_modal.set_template_content({
		"earnings": catch_value,
		"savings": balance,
		"room_cost": room_cost,
		"food_cost": actual_food_cost,
		"balance": final_balance,
		"comment": comment
	})

	balance = final_balance
	day += 1
	player.reset(player.max_energy / (meals_skipped + 1))
	if level + 1 < level_scenes.size():
		level += 1
	else:
		level = 1
	load_level(level_scenes[level])
	
	get_tree().paused = true
	level_end_modal.visible = true
