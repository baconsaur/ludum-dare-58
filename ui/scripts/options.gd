extends Control

@onready var music_bus = AudioServer.get_bus_index("Music")
@onready var sfx_bus = AudioServer.get_bus_index("SFX")
@onready var music_slider = $Music/Slider
@onready var sound_slider = $SFX/Slider

func _ready():
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus))
	sound_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus))

func _on_music_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(value))

func _on_sfx_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(value))
