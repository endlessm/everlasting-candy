extends Control

var _game := preload("res://Scene/Game.tscn") as PackedScene

@onready var MainWorldSelector = $MainWorldSelector
@onready var ExtraWorldSelector = $ExtraWorldSelector
@onready var SettingsSelector = $SettingsSelector
@onready var AudioSelector = $AudioSelector

func _enter_world(world: String) -> void:
	global.load_levels(world)
	global.level = global.firstLevel
	get_tree().change_scene_to_packed(_game)
	global.start_music()


func _on_main_world_selected() -> void:
	_enter_world(global.DEFAULT_WORLD)


func _on_extra_worlds_button_pressed() -> void:
	MainWorldSelector.visible = false
	ExtraWorldSelector.visible = true


func _on_back_button_pressed() -> void:
	ExtraWorldSelector.visible = false
	MainWorldSelector.visible = true


func _on_main_world_selector_settings_selected() -> void:
	MainWorldSelector.visible = false
	SettingsSelector.visible = true


func _on_settings_selector_audio() -> void:
	SettingsSelector.visible = false
	AudioSelector.visible = true


func _on_settings_selector_back() -> void:
	SettingsSelector.visible = false
	MainWorldSelector.visible = true


func _on_audio_selector_audioback() -> void:
	AudioSelector.visible = false
	SettingsSelector.visible = true
