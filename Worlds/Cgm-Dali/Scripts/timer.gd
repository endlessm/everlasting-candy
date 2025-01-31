extends Control

@export var max_time: int
@export var anim_player : AnimationPlayer
@export var label : Label
@export var warning_time : int
var cur_time

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cur_time = max_time
	
	#var tween := create_tween()
	#tween.set_trans(Tween.TRANS_BACK)
	#tween.tween_property(self, "global_position", vec)
	#

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	cur_time -= delta
	if (cur_time < 0):
		cur_time = 0
	var formatted_time = str(int(cur_time))
	label.text = formatted_time
	
	if (cur_time < warning_time):
		_anim_play()
	
	if (cur_time == 0):
		_time_out()
	
# player died when running out
func _time_out():
	#anim_player.play("")
	var player = get_tree().get_first_node_in_group("player")
	if (player):
		player.died.emit()
	
func _anim_play():
	anim_player.play("low_on_time")
