extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready():
	var world_textures := ResourceFinder.load_world_assets(self, "Explosion")
	if world_textures:
		sprite_2d.texture = world_textures.pick_random()
