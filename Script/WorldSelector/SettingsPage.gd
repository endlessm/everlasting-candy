extends Control

signal back

@onready var music_slider : HSlider = %MusicSlider
@onready var sfx_slider : HSlider = %SfxSlider

func _ready() -> void:
	_initialise_slider(music_slider, "Music")
	_initialise_slider(sfx_slider, "Sfx")


func _initialise_slider(slider: Slider, bus: String):
	slider.value = Settings.get_volume(bus)
	slider.value_changed.connect(_on_slider_value_changed.bind(bus))


func _on_slider_value_changed(value: float, bus: String) -> void:
	Settings.set_volume(bus, value)


func _on_visibility_changed() -> void:
	if self.visible and music_slider:
		music_slider.grab_focus()


func _input(event: InputEvent) -> void:
	if self.visible and event.is_action_pressed("ui_cancel"):
		back.emit()


func _on_back_button_pressed() -> void:
	back.emit()
