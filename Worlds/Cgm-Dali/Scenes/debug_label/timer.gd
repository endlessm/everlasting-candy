extends Label

var time = 0
var timer = 99

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += 1.0 * delta
	text = str(timer - int(time))
