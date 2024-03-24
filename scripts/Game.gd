extends Control


@onready var player : CharacterBody3D = $Player
@onready var playerCam : Camera3D = get_node("%PlayerCam")

var deltaG : float

const MAPCAM_HEIGHT = 20

var level := preload("res://scenes/Level.tscn")

enum State {
	EXPLORE,
	COMBAT,
	EXTRACTING
}
var state : State = State.EXPLORE

#enum Turn {
	#PLAYER,
	#ENEMY,
	#DELAY
#}
#var turn : Turn

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().root.ready

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta : float):
	deltaG = delta
	
	turnCam()
	moveCam()
	
	pass



func restart():
	createNewLevel()
	
	state = State.EXPLORE
	#turn = Turn.PLAYER
	
func createNewLevel():
	#level = Level.instantiate()
	
	var startPos = level.startTile.position
	player.position = startPos
	player.rotation.y = (3*PI)/2
	playerCam.transform = player.transform




func turnCam():
	#if get_parent().instantTurn:
		instTurn()
	#else:
		#smoothTurn()
		
func instTurn():
	playerCam.rotation.y = player.rotation.y
	
func smoothTurn():
	var turnSpeed = deltaG * get_parent().turnSpeed
	playerCam.rotation.y = lerp_angle(playerCam.rotation.y, player.rotation.y, turnSpeed)
	
func moveCam():
	#if get_parent().instantMove:
		instMove()
	#else:
		#smoothMove()
	
	#%MapCam.position = playerCam.position
	#%MapCam.position.y = MAPCAM_HEIGHT
	

func instMove():
	playerCam.position = player.position
	
func smoothMove():
	var moveSpeed = deltaG * get_parent().moveSpeed
	playerCam.position = playerCam.position.lerp(player.position, moveSpeed)
