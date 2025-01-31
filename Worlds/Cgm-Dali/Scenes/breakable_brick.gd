extends Node2D

@export var particles : GPUParticles2D
@export var static_body : StaticBody2D
@export var area_2d : Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_2d.body_entered.connect(_on_body_entered)
	particles.finished.connect(_break_block)

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D):
	particles.emitting = true
	static_body.visible = false
	
	
func _break_block():
	queue_free()
	
