extends Node

const MAIN_MENU_SCENE := preload("res://Scene/WorldSelector.tscn") as PackedScene
var _world_rx := RegEx.create_from_string("^res://(?<world>.+)/World.tscn$")

## Proxy object for the 'window' DOM object, or null if not running on the web
var _window: JavaScriptObject


func _ready() -> void:
	if OS.has_feature("web"):
		_window = JavaScriptBridge.get_interface("window")
		_restore_from_hash.call_deferred()


## On the web, load the world indicated by the URL hash, if any.
func _restore_from_hash():
	var hash := _window.location.hash as String
	if hash:
		var world := hash.right(-1).uri_decode()
		var scene := "res://" + world + "/World.tscn"
		if ResourceLoader.exists(scene):
			change_to_file(scene)
		else:
			print("No world found matching ", hash, "; ignoring")


## On the web, update or clear the URL hash to indicate the current world.
func _set_hash(hash: String):
	if _window:
		var url = JavaScriptBridge.create_object("URL", _window.location.href)
		url.hash = "#" + hash
		# Replace the current URL rather than simply updating window.location to
		# avoid creating misleading history entries that don't work if you press
		# the browser's back button.
		_window.location.replace(url.href)


## Switch to the given scene
func change_to_file(path: String):
	var rx_match := _world_rx.search(path)
	if rx_match:
		_set_hash(rx_match.get_string("world"))

	var err := get_tree().change_scene_to_file(path)
	if err != OK:
		push_error("Failed to open ", path, ": ", error_string(err))


## Switch to the main menu scene
func change_to_menu() -> void:
	_set_hash("")
	var err := get_tree().change_scene_to_packed(MAIN_MENU_SCENE)
	if err != OK:
		push_error("Failed to open main menu: ", error_string(err))
