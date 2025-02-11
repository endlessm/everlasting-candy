extends Node2D

@export var particles : GPUParticles2D
@export var static_body : StaticBody2D
@export var area_2d : Area2D
@export var area_2d_above : Area2D

@onready var NodeAudio := $Audio


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_2d.body_entered.connect(_on_body_entered)
	#area_2d_above.body_entered.connect(_on_body_entered_above)
	#area_2d_above.body_exited.connect(_on_body_entered_above)
	particles.finished.connect(_break_block)

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D):
	particles.emitting = true
	var goobers: Array[Node2D] = area_2d_above.get_overlapping_bodies()
	# var player = get_tree().get_first_node_in_group("player") # OLD METHOD
	for goober in goobers:
		body.stomped.emit(goober)
		
	
	static_body.queue_free()
	area_2d.queue_free()
	
	NodeAudio.play()
	
	
func _break_block():
	
	
	queue_free()
	
