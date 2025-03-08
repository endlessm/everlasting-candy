extends CharacterBody2D  # CharacterBody2D gives us built-in physics properties for 2D movement

signal stomped(goober: CharacterBody2D)  # Sent when player jumps on an enemy
signal died                              # Sent when player is hit by an enemy

## If false, the player cannot be moved and does not interact with its
## environment: it just performs its idle animation, as needed for a title
## or world-complete level.
@export var interactive := true  # Makes this variable appear in the Inspector panel

# Get references to child nodes when the scene is loaded
@onready var NodeSprite := $Sprite2D      # The player's visible sprite
@onready var NodeArea2D := $Area2D        # Area for detecting collisions with enemies
@onready var NodeAudio := $Audio          # Sound effects node
@onready var NodeAnim := $AnimationPlayer # Controls animations

# Movement physics variables
var vel := Vector2.ZERO    # Current velocity (speed and direction)
var spd := 60.0            # Horizontal movement speed
var grv := 150.0           # Gravity strength (how fast we fall)
var jumpSpd := 133.0       # Initial jump velocity
var termVel := 400.0       # Terminal velocity (maximum falling speed)
var onFloor := false       # Tracks if player is standing on ground
var jump := false          # Tracks if player is currently jumping

func _ready() -> void:  # Runs once when the player first appears
	var world_textures := ResourceFinder.load_world_assets(self, "Player")  # Try to load player textures
	if world_textures:
		NodeSprite.texture = world_textures.pick_random()  # Choose a random texture

func _physics_process(delta):  # Runs every physics frame (60 times/second)
	if not interactive:
		return  # Skip all movement if player isn't interactive
		
	# gravity
	vel.y += grv * delta  # Apply gravity (delta makes movement consistent regardless of frame rate)
	vel.y = clamp(vel.y, -termVel, termVel)  # Keep falling speed within limits
	
	# horizontal input
	var btnx = Input.get_axis("left", "right")  # Get input (-1 to 1 value)
	vel.x = btnx * spd  # Move left or right based on input
	
	# jump
	if onFloor:
		if Input.is_action_just_pressed("jump"):
			jump = true
			vel.y = -jumpSpd  # Negative Y means moving upward
			NodeAudio.play()  # Play jump sound
	elif jump:
		# Variable jump height based on how long the button is held
		if not Input.is_action_pressed("jump") and vel.y < jumpSpd / -3:
			jump = false
			vel.y = jumpSpd / -3  # Cut the jump short if button is released
			
	# apply movement
	velocity = vel  # Set the built-in velocity property
	move_and_slide()  # Handle actual movement and collisions
	position = global.wrapp(position)  # Wrap player around screen edges
	
	# check for Goobers
	var hit = Overlap()  # Check if we hit any enemies
	if !hit:
		if velocity.y == 0:
			vel.y = 0
		# check for floor 0.1 pixel down
		onFloor = test_move(transform, Vector2(0, 0.1))  # Small check to detect ground
		
	# sprite flip
	if btnx != 0:
		NodeSprite.flip_h = btnx < 0  # If moving left, flip the sprite
		
	# animation
	if onFloor:
		if btnx == 0:
			TryLoop("Idle")  # If on floor and not moving, play idle animation
		else:
			TryLoop("Run")   # If on floor and moving, play run animation
	else:
		TryLoop("Jump")      # If in air, play jump animation

func Overlap():  # Checks for enemy collisions and handles responses
	var hit = false
	for o in NodeArea2D.get_overlapping_areas():  # Loop through overlapping areas
		var par = o.get_parent()
		print ("Overlapping: ", par.name)  # Debug message
		
		if par is Goober:  # If the overlapping object is an enemy
			var above = position.y - 1 < par.position.y  # Check if player is above enemy
			
			if onFloor or (vel.y < 0.0 and !above):
				died.emit()  # Player gets hurt if hit from side or below
			else:
				hit = true
				jump = Input.is_action_pressed("jump")  # Check if jump button is held
				vel.y = -jumpSpd * (1.0 if jump else 0.6)  # Higher bounce if jump is held
				stomped.emit(par)  # Send the stomped signal with enemy reference
				
	return hit

func TryLoop(arg : String):  # Changes animations only if needed
	if arg == NodeAnim.current_animation:
		return false  # Already playing this animation, no change needed
	else:
		NodeAnim.play(arg)  # Play the new animation
		return true  # Animation was changed
