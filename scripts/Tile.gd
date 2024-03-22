extends StaticBody3D

class_name Tile

var wallScene = preload("res://scenes/Wall.tscn")

var tiles : Array[Tile]
var maxTiles := 32

enum Type {
	START,
	STAIRS,
	WALL
}
var type : Type

var front = Vector3i(2, 0, 0)
var left = Vector3i(0, 0, -2)
var right = Vector3i(0, 0, 2)
var back = Vector3i(-2, 0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	buildWalls()
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

func buildWalls():
	match type:
		Type.START:
			addWall(back)
			addWall(left)
			addWall(right)

func addWall(pos : Vector3i):
	var wall = wallScene.instantiate()
	pos.y += 2
	wall.position = pos
	
	if pos.z == 0:
		wall.rotation.y = PI/2
	
	add_child(wall)

