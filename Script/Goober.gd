extends CharacterBody2D
class_name Goober

@onready var NodeCast := $RayCast2D
@onready var NodeSprite := $Sprite2D

var spd := 30.0
var vel := Vector2(spd, 0.001)
var flip_clock := 1.0

func _ready():
	var world_textures := ResourceFinder.load_world_assets(self, "Goober")
	if world_textures:
		NodeSprite.texture = world_textures.pick_random()

	# change starting direction
	if randf() > 0.5:
		flip()

func _physics_process(delta):
	flip_clock += delta

	if !NodeCast.is_colliding():
		flip()

	velocity = vel
	move_and_slide()
	if velocity.x == 0:
		flip()

	position = global.wrapp(position)

func flip():
	if flip_clock < 0.1: return
	vel.x = -vel.x
	NodeSprite.flip_h = !NodeSprite.flip_h
	flip_clock = 0.0
