extends AnimatedSprite3D

@onready var sprite = self

var level : int
var health : int
var strength : int
var armor : int
var accuracy : int
var experience : int

enum EnemyType {
	BAT,
	FROG
}
var type : EnemyType

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.scale = Vector3(2.5, 2.5,1)
	sprite.sprite_frames = load("res://Assets/enemies/Enemies_Sprite_Frame.tres")
	
	var randNum = randi_range(0, EnemyType.size()-1)
	
	match randNum:
		0: 
			type = EnemyType.BAT
			sprite.animation = "Bat"
			level = 1
			health = 8
			strength = 4
			armor = 0
			accuracy = 70
			experience = 20
		1:
			type = EnemyType.FROG
			sprite.animation = "Frog"
			level = 1
			health = 8
			strength = 4
			armor = 0
			accuracy = 70
			experience = 20


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
