extends CharacterBody3D

@onready var game = get_parent()
@onready var State = game.State

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game.state == State.EXPLORE:
		turn()
		move()

func turn():
	if Input.is_action_just_pressed("turn_left"):
		print("left rotation")
		rotation.y += PI/2
	if Input.is_action_just_pressed("turn_right"):
		print("right rotation")
		rotation.y -= PI/2
	
	if rotation.y < 0:
		rotation.y += PI * 2
	elif rotation.y >= PI * 2:
		rotation.y -= PI * 2
	
	rotation.y = snapped(rotation.y, PI/2)
	

func move():
	var movement := Vector3.ZERO
	if Input.is_action_just_pressed("move_forward") && !$RayForward.is_colliding():
		print("forward")
		movement = calc_forw_move()
	
	if Input.is_action_just_pressed("move_backward") && !$RayBackward.is_colliding():
		print("backward")
		movement = calc_forw_move()
		movement.z = -movement.z
		movement.x = -movement.x
	
	if Input.is_action_just_pressed("move_left") && !$RayLeft.is_colliding():
		print("left")
		movement = calc_forw_move()
		var temp = movement.x
		movement.x = movement.z
		movement.z = -temp
	
	if Input.is_action_just_pressed("move_right") && !$RayRight.is_colliding():
		print("right")
		movement = calc_forw_move()
		var temp = movement.x
		movement.x = -movement.z
		movement.z = temp
	
	move_and_collide(movement)
	position = snapped(position, Vector3(4,2,4))


func calc_forw_move() -> Vector3:
	if is_zero_approx(rotation.y):
		return Vector3(0,0,-4)
	elif is_equal_approx(rotation.y, PI/2):
		return Vector3(-4,0,0)
	elif is_equal_approx(rotation.y, PI):
		return Vector3(0,0,4)
	elif is_equal_approx(rotation.y, (3*PI)/2):
		return Vector3(4,0,0)
	
	return Vector3.ZERO

