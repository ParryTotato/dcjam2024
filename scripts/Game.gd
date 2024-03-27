extends Control


@onready var player : CharacterBody3D = $Player
@onready var playerCam : Camera3D = get_node("%PlayerCam")

var deltaG : float

var instantTurn := false
var instantMove := false

var globalTurnSpeed := 10
var globalMoveSpeed := 10

const MAPCAM_HEIGHT = 20

enum State {
	EXPLORE,
	COMBAT,
	EXTRACTING
}
var state : State = State.EXPLORE

var Enemy := preload("res://Scenes/Enemy.tscn")
var enemy : AnimatedSprite3D

enum Turn {
	PLAYER,
	ENEMY,
	DELAY
}
var turn : Turn

# Called when the node enters the scene tree for the first time.
func _ready():
	print("hi")
	await get_tree().root.ready

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta : float):
	deltaG = delta
	
	turnCam()
	moveCam()
	
	var curTile = player.getPosition()
	
	if state == State.EXPLORE:
		startCombat()

func restart():
	createNewLevel()
	
	state = State.EXPLORE
	turn = Turn.PLAYER
	
func createNewLevel():
	#var startPos = level.startTile.position
	#player.position = startPos
	player.rotation.y = (3*PI)/2
	playerCam.transform = player.transform
	spawnEnemies()

func spawnEnemies():
	enemy = Enemy.instantiate()
	#enemy.position = Vector2(370, 840)

func startCombat():
	pass


func turnCam():
		smoothTurn()
		
func instTurn():
	playerCam.rotation.y = player.rotation.y
	
func smoothTurn():
	var turnSpeed = deltaG * globalTurnSpeed
	playerCam.rotation.y = lerp_angle(playerCam.rotation.y, player.rotation.y, turnSpeed)
	
func moveCam():
		smoothMove()
	

func instMove():
	playerCam.position = player.position
	
func smoothMove():
	var moveSpeed = deltaG * globalMoveSpeed
	playerCam.position = playerCam.position.lerp(player.position, moveSpeed)
