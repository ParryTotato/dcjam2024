extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass;
	# Get the other object
	# var node = get_node("../Tile Array Object");
	# Generate tile array
	# var tileArr = node.generate_tile_array(5);
	# spawn_tiles(tileArr);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Loops through the linked tile array and spawns the relevant objects
func spawn_tiles(tileArr):
	
	# I know for a fact that the tile array itself is fine
	# And it's not even being used yet anyway, I'll add the loop once I get this to work
	
	var loaded_scene = preload("res://Scenes/tiles.tscn");
	var tiles_object = loaded_scene.instance();
	tiles_object.position = Vector2(0,0);
	add_child(tiles_object);
