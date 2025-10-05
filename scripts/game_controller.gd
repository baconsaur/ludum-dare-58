extends Node2D

@onready var player = $Player
@onready var hud = $HUD
@onready var energy_bar = $HUD/MarginContainer/EnergyBar
@onready var game_over_modal = $HUD/GameOver

var day: int = 0

func _ready() -> void:
	game_over_modal.visible = false
	
	player.connect("energy_change", update_energy)
	player.connect("died", game_over)

func update_energy(energy):
	energy_bar.value = energy

func game_over():
	get_tree().paused = true
	game_over_modal.visible = true
