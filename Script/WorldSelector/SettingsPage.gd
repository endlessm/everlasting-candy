extends Control

signal back

const SETTINGS_PATH := "user://settings.cfg"
const VOLUME_SECTION := "Volume"
var _settings := ConfigFile.new()
var _loading = true

@onready var music_slider : HSlider = %MusicSlider
@onready var sfx_slider : HSlider = %SfxSlider

func _ready() -> void:
	var err := _settings.load(SETTINGS_PATH)
	if err != OK and err != ERR_FILE_NOT_FOUND:
		print("Failed to load %s: %s" % [SETTINGS_PATH, err])

	_initialise_slider(music_slider, "Music")
	_initialise_slider(sfx_slider, "Sfx")

	_loading = false


func _initialise_slider(slider: Slider, bus: String):
	var level = _settings.get_value(VOLUME_SECTION, bus, 0)

	slider.value_changed.connect(_on_slider_value_changed.bind(slider, bus))
	slider.value = level


func _on_slider_value_changed(value: float, slider: Slider, bus: String) -> void:
	var bus_idx = AudioServer.get_bus_index(bus)

	AudioServer.set_bus_volume_db(bus_idx, value)
	var mute := value == slider.min_value
	AudioServer.set_bus_mute(bus_idx, mute)

	if not _loading:
		_settings.set_value(VOLUME_SECTION, bus, value)
		var err := _settings.save(SETTINGS_PATH)
		if err != OK:
			print("Failed to save settings to %s: %s" % [SETTINGS_PATH, err])


func _on_visibility_changed() -> void:
	if self.visible and music_slider:
		music_slider.grab_focus()


func _input(event: InputEvent) -> void:
	if self.visible and event.is_action_pressed("ui_cancel"):
		back.emit()


func _on_back_button_pressed() -> void:
	back.emit()
