extends Control


@onready var player : CharacterBody3D = $Player
@onready var playerCam : Camera3D = get_node("%PlayerCam")
@onready var healthbar = get_node("Player/CanvasLayer/Healthbar")

var deltaG : float

var instantTurn := false
var instantMove := false

var globalTurnSpeed := 10
var globalMoveSpeed := 10


var health
var is_alive
var enemiesKilled := 0

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
	health = 100
	healthbar.init_health(health)
	await get_tree().root.ready

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta : float):
	deltaG = delta
	
	turnCam()
	moveCam()
	
	#TODO: Add in the random logic for starting combat
	if state == State.EXPLORE and Input.is_action_just_pressed("ui_page_up"):
		startCombat()
		
	if state == State.COMBAT:
		if enemy != null:
			enemy.position.y = lerp(enemy.position.y, 280.0, delta * 3)
			#TODO: Update Enemy Health Bar based on damage taken
		
		if enemy != null && enemy.health <= 0:
			enemy.scale = enemy.scale.move_toward(Vector3.ZERO, delta * 10)
			if enemy.scale.x < 0.5:
				enemyKilled()

func restart():
	createNewLevel()
	startExplore()
	
	state = State.EXPLORE
	turn = Turn.PLAYER
	
func createNewLevel():
	#var startPos = level.startTile.position
	#player.position = startPos
	player.rotation.y = (3*PI)/2
	playerCam.transform = player.transform

func enemyKilled():
	startExplore()
	enemiesKilled += 1

func startExplore():
	if enemy != null:
		enemy.queue_free()
	
	state = State.EXPLORE

func startCombat():
	state = State.COMBAT
	turn = Turn.PLAYER
	enemy = Enemy.instantiate()
	enemy.position = Vector3(370, 840, 0)
	%GameObject/MarginContainer/CombatContainer/CombatViewport.add_child(enemy)
	#TODO: Create Enemy Health Bar and set max value
	print("Combat should start")

func switchTurn():
	if enemy == null || enemy.health == 0:
		turn = Turn.PLAYER
		return
	
	if turn == Turn.ENEMY:
		enemyAttack()

func playerAttack(damage : int):
	if turn != Turn.PLAYER || state != State.COMBAT || enemy == null:
		return
	
	enemy.health -= player.strength
	turn = Turn.ENEMY

func enemyAttack():
	var hasAttacked = false
	
	if !hasAttacked && player.health > 0:
		player.health -= enemy.strength
		healthbar._set_health(player.health)
		hasAttacked = true
	
	if player.health <= 0:
		_die()
	
	turn = Turn.PLAYER


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

func _set_health(value):
	_set_health(value)
	if health <= 0 && is_alive:
		_die()
		
		healthbar.health = health
		
func _die():
	get_tree().paused = true
