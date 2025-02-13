## Simulates candy falling from the sky behind the game level. The spawn rate
## increases as the player progresses through the levels; this is controlled
## with [member progress].
class_name CandySpawner
extends Node2D

## The progress of the player through the game, from 0.0 (on the title screen)
## to 1.0 (on the win screen). Candy spawns faster as this value increases.
@export_range(0.0, 1.0) var progress := 0.0:
	set = _set_progress

## The textures to use for the candy falling in the background.
## If this list is empty, the png files in the directory Image/Candy adjacent to
## the world will be used; if no such files exist, a default candy will be used.
@export var candy_textures : Array[Texture2D] = []
var _texture_index := 0

const FALLBACK_TEXTURE : Texture2D = preload("res://Image/Candy.png")
var _MAX_SIZE = FALLBACK_TEXTURE.get_size().x

var delay := 3.0
var timer := 0.0


var active := []
var idle := []


func _set_progress(new_progress):
	progress = new_progress

	var old_delay = delay
	if progress >= 1:
		delay = 0.15
	else:
		delay = lerp(3.0, 0.333, progress)

	timer -= (old_delay - delay)


func _ready() -> void:
	if not candy_textures:
		candy_textures = ResourceFinder.load_world_assets(self, "Candy")

	if not candy_textures:
		candy_textures = [FALLBACK_TEXTURE]

	candy_textures.shuffle()
	for candy_texture in candy_textures:
		var c := _make_sprite()
		c.position.y = -_MAX_SIZE
		idle.push_back(c)


func _make_sprite() -> Sprite2D:
	var c := Sprite2D.new()
	c.texture = candy_textures[_texture_index]
	var dimensions = c.texture.get_size()
	if dimensions.x > _MAX_SIZE or dimensions.y > _MAX_SIZE:
		c.scale *= (_MAX_SIZE / max(dimensions.x, dimensions.y))
	_texture_index += 1
	_texture_index %= candy_textures.size()
	add_child(c)
	return c


func _process(delta):
	timer -= delta

	for i in active:
		i.position.y += 60.0 * delta
		if i.position.y > 160:
			idle.append(i)

	for i in idle:
		active.erase(i)

	if timer < 0:
		timer = delay
		var c: Sprite2D
		if idle.size() > 0:
			c = idle.pop_front()
		else:
			c = _make_sprite()
		active.append(c)
		c.position.y = -16
		c.position.x = randi_range(0, 144)
