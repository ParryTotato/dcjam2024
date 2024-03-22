extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$Game.restart()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("escape"):
		#add in menu logic
		pass 
