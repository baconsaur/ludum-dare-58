extends Node2D

@onready var player = $Player
@onready var hud = $HUD
@onready var energy_bar = $HUD/MarginContainer/EnergyBar
@onready var game_over_modal = $HUD/GameOver
@onready var level_end_modal = $HUD/LevelEnd

var day: int = 1

func _ready() -> void:
	game_over_modal.visible = false
	level_end_modal.visible = false
	
	player.connect("energy_change", update_energy)
	player.connect("died", game_over)
	player.connect("day_end", level_complete)
	
	energy_bar.max_value = player.max_energy

func update_energy(energy):
	energy_bar.value = energy

func game_over():
	get_tree().paused = true
	game_over_modal.visible = true

func level_complete():
	get_tree().paused = true
	level_end_modal.visible = true
