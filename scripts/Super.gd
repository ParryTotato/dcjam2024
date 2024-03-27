extends Control

var instantTurn := false
var instantMove := false

var turnSpeed := 10
var moveSpeed := 10

# Called when the node enters the scene tree for the first time.
func _ready():
	$Game.restart()
	get_tree().paused = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("escape"):
		#add in menu logic
		pass 
