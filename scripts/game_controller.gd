extends Node2D

@onready var player = $Player
@onready var hud = $HUD
@onready var energy_bar = $HUD/MarginContainer/EnergyBar

func _ready() -> void:
	player.connect("energy_change", update_energy)

func update_energy(energy):
	energy_bar.value = energy
