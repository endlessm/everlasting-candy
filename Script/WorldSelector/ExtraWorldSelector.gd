extends Control

signal world_selected(world: String)
signal back

const WORLDS_DIR := "res://Worlds/"
const SAMPLE_WORLD := "Sample"

@onready var Scroll: ScrollContainer = %Scroll
@onready var ExtraWorldsBox: VBoxContainer = %ExtraWorldsBox
@onready var BackButton: Button = %BackButton


func _find_worlds(path) -> Array[String]:
	var worlds_dir = DirAccess.open(path)
	var worlds: Array[String]
	if worlds_dir:
		worlds_dir.list_dir_begin()
		var child := worlds_dir.get_next()
		while child:
			if worlds_dir.current_is_dir():
				worlds.append(child)
			child = worlds_dir.get_next()

	worlds.sort_custom(func (a: String, b: String): return a.naturalnocasecmp_to(b) < 0)

	# Move the sample world to the end
	var ix := worlds.find(SAMPLE_WORLD)
	if ix >= 0:
		worlds.remove_at(ix)
		worlds.push_back(SAMPLE_WORLD)

	return worlds


func _ready() -> void:
	var worlds := _find_worlds(WORLDS_DIR)

	for world in worlds:
		var button = Button.new()
		button.text = world
		button.pressed.connect(_on_world_button_pressed.bind(WORLDS_DIR.path_join(world).path_join("World.tscn")))
		ExtraWorldsBox.add_child(button)


func _on_world_button_pressed(world: String) -> void:
	world_selected.emit(world)


func _on_back_button_pressed() -> void:
	back.emit()


func _input(event: InputEvent) -> void:
	if self.visible and event.is_action_pressed("ui_cancel"):
		back.emit()


func _on_visibility_changed() -> void:
	if self.visible and BackButton:
		BackButton.grab_focus()
		Scroll.scroll_vertical = 0
