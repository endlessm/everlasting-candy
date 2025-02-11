extends Control

@export var max_time: int
@export var anim_player : AnimationPlayer
@export var label : Label
@export var warning_time : int

@onready var timer: Timer = $Timer
@onready var warning_timer: Timer = $WarningTimer
var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = max_time
	timer.timeout.connect(_time_out)
	timer.start()

	warning_timer.wait_time = max_time - warning_time
	warning_timer.timeout.connect(_anim_play)
	warning_timer.start()

	# Hack: we can't find the player here in _ready() because TileMapLayer only
	# instantiates its child scenes at the end of the current frame.
	_find_player.call_deferred()


func _find_player() -> void:
	player = get_tree().get_first_node_in_group("player")
	if player:
		player.died.connect(_stop)


func _stop():
	timer.stop()
	warning_timer.stop()
	anim_player.stop()
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	label.text = str(ceil(timer.time_left))

	if get_tree().get_node_count_in_group("goober") == 0:
		_stop()


# player died when running out
func _time_out():
	anim_player.stop()
	if player:
		player.died.emit()


func _anim_play():
	anim_player.play("low_on_time")
