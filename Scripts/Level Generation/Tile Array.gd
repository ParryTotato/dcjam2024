extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	# This function only generates the tile array (which is an multi-dimensional array of strings)
	# It does NOT spawn any physical objects in the level, that still needs to be done
	# It also does not denote where the level exit/stairs down should be located
	# However, all floor tiles are guaranteed to be contiguous, so you can just pick one of those at random
	# This function uses "W" to denote a wall tile and "." to denote a floor tile.
	generate_tile_array(5);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

# This function returns a tile array for 3x3 floor filled with the specified number of rooms
func generate_tile_array(numRooms,lockEntrance = false):
	# numRooms = 1 will generate only the bottom center room
	# numRooms = 9 will fill all nine squares
	# lockEntrance will eventually replace the bottom center room with Yomag's prebuilt entrance hall
	# That functionality has yet to be implemented
	
	# For this to work properly, the following things must be true:
	# 1. All rooms must be the same size.
	# 2. All rooms must be square.
	# 3. All rooms must have their exits/entrances in the exact center of each edge.
	# 4. numRooms must range between 2 and 9.
	
	# Convenience constants. Change these to adjust room size, grid size, etc.
	var roomSize = 11; # This function currently only works for square rooms (i.e. roomSize 11 = 11x11 rooms)
	var gridSize = 3; # The number of rooms, horizontally and vertically, per floor
	# Calculate total number of cells in each row/column based on the above
	var cellNum = roomSize * gridSize;
	# Define a new array
	var tileArr = [];
	# Fill it with arrays (to make a 2D array)
	for k in cellNum: # Can I really only do for/each loops? Godot is B tier at best
		# I hate indentation based languages so much
		tileArr.append([]); # Add an empty array for each entry in the first dimension
		# Go to second layer so we can initialize a default value
		for l in cellNum:
			# Initialize the value
			tileArr[k].append(null);
	
	# First, determine which cells we actually want to fill, and with what type of room
	var gridConnection = [];
	# Creates a square grid of empty arrays matching the grid size
	for k in gridSize * gridSize:
		# Not technically square but whatever, it's the right size
		gridConnection.append([]);
	# Yomag wanted the bottom center room to be the "entrance" so all floor layouts start there
	# Can't be bothered to make this dynamic so it's just hardcoded to start from grid square #8
	var source = 7; # Which is index seven, because arrays start from zero
	# Loop repeatedly, adding connections between random existing rooms until it has enough
	# This does NOT distribute connections perfectly evenly or anything like that
	# It's significantly more likely to connect the rooms closer to the entrance
	# But not only is this way easier to code, it kind of makes sense for a dungeon anyway
	# Probably fine to have multiple paths near the entrance but have more dead ends near the exit
	# If you don't like this formation, or you have a better idea, I'm open to suggestions
	while count_rooms(gridConnection) < numRooms:
		# Will keep adding connections randomly
		# It is possible for add_connection() to fail and do nothing
		# However, it will never fail on the FIRST connection (the one with source = 7)
		# If it did somehow fail, it would never be able to generate another connection
		# Because it can only generate a connection from rooms that already have at least one
		gridConnection = add_connection(gridConnection,source,gridSize);
		# Randomize the source room AFTER the connection has been added
		source = randi_range(0,8);
		# Reroll until the source room is one that already has at least one connection
		# Does Godot support do/until loops? We'll never know because I'm not even going to try
		while gridConnection[source].size() == 0:  
			source = randi_range(0,8);
	# Debugger that prints out the connections for each room in a somewhat readable format
	# Apparently Godot doesn't support multi-line comments, that's pretty hype
	# I'm moving this language down to C tier.
	# var count = 0;
	# for k in gridConnection:
	# 	# Print each line to console separately
	# 	print(str(count) + ": " + str(k));
	# 	# Increment index
	# 	count += 1;
		
	# Once all the grid connections have been formed, we must pick out rooms to match those connections
	var tempRoom = null;
	# Counter used to track the current index
	# Because Godot only has for-each loops, we don't actually know what index we're at
	# If there is a way to check, I don't know how to do it, so this is easier
	var count = 0;
	# The type of room we roll is dependent on the number and type of connections
	for k in gridConnection:
		# For each entry in grid connections, we determine the type of room it wants
		if k.size() == 4:
			# 4 connections = use center formation
			tempRoom = get_random_level("Center");
		elif k.size() == 3:
			# 3 connections = use T-intersection formation
			tempRoom = get_random_level("T-Inter");
		elif k.size() == 2:
			# 2 connections can be either linear or corner
			# We just hardcode this filter
			if k.has("N") && k.has("S"):
				tempRoom = get_random_level("Linear");
			elif k.has("E") && k.has("W"):
				tempRoom = get_random_level("Linear");
			else:
				tempRoom = get_random_level("Corner");
		elif k.size() == 1:
			# 1 connection is a dead end
			tempRoom = get_random_level("Dead End");
		else:
			# 0 connections is a blank room (all walls)
			tempRoom = blank_room();
			
		# Rotate the room based on which entrances are actually needed
		# Just gonna hardcode these because I can't be bothered to make it dynamic
		# That means these will have to be updated if the room size stops being 11x11
		# N entrance is located at index 5, E entrance is located at index 65
		# S entrance is located at index 115, W entrance is located at index 55
		while tempRoom[5] == "W" && k.has("N"):
			# Entrance does NOT line up, rotate map.
			tempRoom = rotate_map(tempRoom,roomSize);
		while tempRoom[65] == "W" && k.has("E"):
			# Entrance does NOT line up, rotate map.
			tempRoom = rotate_map(tempRoom,roomSize);
		while tempRoom[115] == "W" && k.has("S"):
			# Entrance does NOT line up, rotate map.
			tempRoom = rotate_map(tempRoom,roomSize);
		while tempRoom[55] == "W" && k.has("W"):
			# Entrance does NOT line up, rotate map.
			tempRoom = rotate_map(tempRoom,roomSize);
		# Theoretically, doing multiple rounds of rotations could rotate them back out of position
		# However, we already guaranteed that the rooms will match the correct pattern
		# If any of the rooms do NOT have entrances in the right place, this will break!
		# Make sure there are no accidental blank rooms or misplaced entrances
		
		# Once the array of room tiles has been retrieved, we need to overwrite the actual tiles
		
		# Calculate the corner positions of each room
		# e.g. if count = 0 and gridSize = 3 we need to overwrite the first 11 entries of the first 11 rows
		var startX = roomSize * (count % gridSize); # e.g. 1/4/7 all start at 11
		var endX = startX + roomSize - 1;
		# This causes an integer division warning but I don't think I care enough
		var startY = roomSize * floor(count / gridSize); # e.g. 3/4/5 all start at 11
		var _endY = startY + roomSize - 1; # This doesn't actually get used but it's nice to have
		# This variable tracks which row and column we're on
		var x = startX;
		var y = startY;
		# Print these values for debugging purposes
		# print(str(startX) + "/" + str(startY) + "/" + str(endX) + "/" + str(_endY));
		
		# Remember that tempRoom will be a 1D array!
		for l in tempRoom:
			# l will be the corresponding string ("W" for walls, "." for floor tiles)
			tileArr[x][y] = l;
			# Increment x
			x += 1;
			# If this exceeds the right side of the room, go to next column
			if x > endX:
				x = startX;
				y += 1;
		
		# Finally, increment counter variable for the main loop
		count += 1; # Not to be confused with count2, which is only used in the sub-loop
		
	# Debugger that prints out the tiles for the whole floor in a somewhat readable format
	for k in tileArr:
		# Print each line to console separately
		print(str(k));
	
	# Final return line
	return tileArr;

# When given a connection grid, will add an additional connection in a random direction
func add_connection(gridConnection,source,size):
	# gridConnection is the array that gets passed to this function
	# source is the index of the room that is adding the connection (should be 0 to 8)
	# size is the size of the grid (in either dimension; currently only supports squares)
	
	# Find the specified array
	var temp = gridConnection[source];
	
	# It will pick one of the four directions to attempt a connection in
	var viableDirections = [];
	# If it's on the top row, it can't add connections upwards
	if source >= size: # e.g. if size is 3, 0/1/2 cannot connect upwards
		viableDirections.append("N");
	# If it's on the right side, it can't add connections to the right
	if source % size < size - 1: # e.g. if size is 3, 2/5/8 cannot connect rightwards
		viableDirections.append("E");
	# If it's on the left side, it can't add connections to the left
	if source % size > 0: # e.g. if size is 3, 0/3/6 cannot connect leftwards
		viableDirections.append("W");
	# If it's on the bottom row, it can't add connections downwards
	if source < size * (size - 1): # e.g. if size is 3, 6/7/8 cannot connect downwards
		viableDirections.append("S");
	
	# If the number of viable directions is equal to the number of connections the room already has...
	# ... cancel out without doing anything (there are no more connections it can add)
	if temp.size() == viableDirections.size():
		return gridConnection;
	
	# Pick a random viable direction
	var dir = viableDirections.pick_random();
	# Do the scuffed do/until loop again
	while temp.has(dir):
		dir = viableDirections.pick_random();
	
	# Add a connection to itself first
	temp.append(dir);
	
	# Then find the corresponding room
	var index = -1;
	# Based on direction
	if dir == "N":
		# The corresponding room will be one row above
		index = source - size;
		# Invert direction
		dir = "S";
	elif dir == "E":
		# The corresponding room will be one column to the right
		index = source + 1;
		# Invert direction
		dir = "W";
	elif dir == "S":
		# The corresponding room will be one row below
		index = source + size;
		# Invert direction
		dir = "N";
	elif dir == "W": # Yes, I know I could just use "else" here, this is for readability
		# The corresponding room will be one column to the left
		index = source - 1;
		# Invert direction
		dir = "E";
	
	# Add a connection to the corresponding room
	gridConnection[index].append(dir);
	
	# Return the modified array
	# I have no idea if Godot treats arrays as modifiable outside of function scope or not
	# And I can't be bothered to find out
	return gridConnection;
	
# Counts the number of rooms that have at least one connection.
func count_rooms(gridConnection):
	# Simply counts the number of rooms that aren't an empty array
	var count = 0;
	# Loop through array
	# I keep forgetting this is a for/each loop, and k is already the array object
	for k in gridConnection:
		# Check if it has a length greater than zero
		if k.size() > 0:
			# Increment counter
			count += 1; # Apparently count++ is invalid syntax?
	
	# Okay, so, I looked it up and apparently there was a deliberate decision not to support ++ and --
	# Apparently it "does not improve readability" and "violates the order expressions are evaluated in"
	# And for this reason, Godot is going straight into D tier.
	# Thanks for listening to my TED talk.
	
	# Return line
	return count;

# Another custom function. Returns a room based on the specified slot
# Slot should be a string: "Center", "T-Inter", "Linear", "Corner", or "Dead End"
# I could make this accept integers 0 through 4, but that's less readable elsewhere
func get_random_level(slot):
	# Retrieves level map: Formatted as [Center, T-Inter, Linear, Corner, Dead End]
	var tempArr = level_map();
	# Returns a random valid value from the levelMap
	if slot == "Center":
		return tempArr[0].pick_random();
	if slot == "T-Inter":
		return tempArr[1].pick_random();
	if slot == "Linear":
		return tempArr[2].pick_random();
	if slot == "Corner":
		return tempArr[3].pick_random();
	if slot == "Dead End":
		return tempArr[4].pick_random();
	# This should never actually happen, so we throw an error if we somehow get to this part of the script
	push_error("Attempted to get_random_level of slot type: " + str(slot));
	
# Maps all the levels we have 
func level_map():
	# I could not figure out how to make a map/library data structure in Godot so we're using an array
	# Feel free to change this to the proper data structure if you actually know what it is
	var levelMap = [];
	# Gigantic tower of values. Formatted like this for readability mostly
	# I used "X" for wall tiles and "." for floor tiles
	var centerData = [ # Start bracket
		
					#Each room is represented by an 11x11 "grid" (actually just a 1D array)
				   ["W",".",".",".",".",".",".",".",".",".","W",
					".",".",".",".",".",".",".",".",".",".",".",
					".",".",".",".",".",".",".",".",".",".",".",
					".",".",".",".",".","W",".",".",".",".",".",
					".",".",".",".","W","W","W",".",".",".",".",
					".",".",".","W","W","W","W","W",".",".",".",
					".",".",".",".","W","W","W",".",".",".",".",
					".",".",".",".",".","W",".",".",".",".",".",
					".",".",".",".",".",".",".",".",".",".",".",
					".",".",".",".",".",".",".",".",".",".",".",
					"W",".",".",".",".",".",".",".",".",".","W"],
					
					#If you can think of a better way to do this feel free to change it
				   [".",".",".",".",".",".",".",".",".",".",".",
					".",".",".",".",".",".",".",".",".",".",".",
					".",".",".",".",".",".",".",".",".",".",".",
					".",".",".",".",".",".",".",".",".",".",".",
					".",".","W","W","W","W","W","W","W",".",".",
					".",".","W","W","W",".",".",".",".",".",".",
					".",".","W","W","W",".",".",".",".",".",".",
					"W","W","W","W","W","W","W",".","W","W","W",
					"W","W","W",".",".",".","W",".","W","W","W",
					"W","W","W",".",".",".",".",".","W","W","W",
					"W","W","W",".",".",".","W","W","W","W","W"],
					
					#I'm sleep deprived and this is the best thing I could come up with
				   ["W","W",".",".",".",".",".",".",".","W","W",
					".",".",".",".",".",".",".",".",".",".",".",
					".",".",".",".",".",".",".",".",".",".",".",
					".",".","W",".",".",".",".",".","W",".",".",
					".",".",".",".",".",".",".",".",".",".",".",
					".",".",".","W",".",".",".","W",".",".",".",
					".",".",".",".",".",".",".",".",".",".",".",
					"W",".",".",".",".",".",".",".",".",".","W",
					"W","W",".",".",".",".",".",".",".","W","W",
					"W","W","W",".",".",".",".",".","W","W","W",
					"W","W","W","W","W",".","W","W","W","W","W"],
					
					#I put comments on all the other rooms so I feel obligated to include this one
				   ["W","W","W",".",".",".",".",".",".",".","W",
					"W","W","W",".",".",".",".",".",".",".","W",
					"W","W","W",".",".",".",".",".",".",".","W",
					"W","W","W","W","W",".","W","W","W","W","W",
					".",".",".","W","W",".","W","W",".",".",".",
					".",".",".","W","W",".","W","W",".",".",".",
					".",".",".","W","W",".","W","W",".",".",".",
					".",".",".","W",".",".",".","W",".",".",".",
					".",".",".",".",".",".",".",".",".",".",".",
					".",".",".",".",".",".",".",".",".","W",".",
					".",".",".",".",".",".",".",".",".",".","."],
					
					#This is the last room so there's no comma after it
				   [".",".",".",".","W",".","W","W","W","W","W",
					".",".",".",".","W",".","W",".",".",".",".",
					".",".",".",".","W",".",".",".",".",".",".",
					".",".",".",".","W",".","W",".",".",".",".",
					"W",".","W","W",".",".",".","W","W","W","W",
					".",".",".",".",".",".",".","W","W",".",".",
					"W","W",".","W",".",".",".","W","W",".","W",
					"W",".",".",".","W",".","W",".",".",".",".",
					"W",".",".",".","W",".","W",".",".",".",".",
					"W",".",".",".","W",".",".",".",".",".",".",
					"W",".",".",".","W",".","W",".",".",".","."]
					
					]; #End bracket
					
	# Second type of room. As a reminder, "W" is a wall tile and "." is a floor tile
	var interData = [ # Start bracket
					
					# Follows the same formatting as the other room types
				   ["W","W","W","W","W",".","W","W","W","W","W",
					"W",".",".",".",".",".",".",".",".",".","W",
					"W",".",".",".",".",".",".",".",".",".","W",
					"W",".",".","W","W",".","W","W",".",".","W",
					"W",".",".","W",".",".",".","W",".",".","W",
					"W",".",".",".",".",".",".",".",".",".",".",
					"W",".",".","W",".",".",".","W",".",".","W",
					"W",".",".","W","W",".","W","W",".",".","W",
					"W",".",".",".",".",".",".",".",".",".","W",
					"W",".",".",".",".",".",".",".",".",".","W",
					"W","W","W","W","W",".","W","W","W","W","W"],
					
					# Last room of this category; no comma
				   ["W","W","W","W","W","W","W","W","W","W","W",
					"W",".",".",".","W",".","W",".",".",".","W",
					"W",".",".",".",".",".",".",".",".",".","W",
					"W",".",".",".",".",".",".",".",".",".","W",
					"W","W",".","W","W","W","W","W",".","W","W",
					".",".",".",".","W","W","W",".",".",".",".",
					"W",".",".",".",".",".",".",".",".",".","W",
					"W",".",".",".",".",".",".",".",".",".","W",
					"W",".",".",".",".",".",".",".",".",".","W",
					"W","W","W",".",".",".",".",".","W","W","W",
					"W","W","W","W","W",".","W","W","W","W","W"]
					
					]; # End bracket
					
	# Third type of room. As a reminder, "W" is a wall tile and "." is a floor tile
	var linearData = [ # Start bracket
					
					# Follows the same formatting as the other room types
				   ["W","W","W","W","W",".","W","W","W","W","W",
					"W","W","W","W","W",".",".",".",".","W","W",
					"W",".",".",".","W","W","W","W",".","W","W",
					"W",".",".",".","W","W","W",".",".",".","W",
					"W",".",".",".","W",".",".",".",".",".","W",
					"W",".",".",".","W",".","W",".",".",".","W",
					"W",".",".",".",".",".","W",".",".",".","W",
					"W",".",".",".","W","W","W",".",".",".","W",
					"W","W",".","W","W","W","W",".",".",".","W",
					"W","W",".",".",".",".","W","W","W","W","W",
					"W","W","W","W","W",".","W","W","W","W","W"],
					
					# Last room of this category; no comma
				   ["W","W","W","W","W",".","W","W","W","W","W",
					"W",".",".",".",".",".",".",".",".",".","W",
					"W",".",".",".",".",".",".",".",".",".","W",
					"W",".",".","W","W","W","W","W",".",".","W",
					"W",".","W","W",".",".",".","W",".",".","W",
					"W","W","W","W",".",".",".","W",".",".","W",
					"W","W",".","W",".",".",".","W",".",".","W",
					"W",".",".","W","W",".","W","W",".",".","W",
					"W",".",".",".",".",".",".",".",".",".","W",
					"W",".",".",".",".",".",".",".",".",".","W",
					"W","W","W","W","W",".","W","W","W","W","W"]
					
					]; # End bracket
					
	# Fourth type of room. As a reminder, "W" is a wall tile and "." is a floor tile
	var cornerData = [ # Start bracket
					
					# Follows the same formatting as the other room types
				   ["W","W","W","W","W","W","W","W","W","W","W",
					"W","W","W","W","W","W",".",".",".",".","W",
					"W","W","W","W","W","W",".",".",".",".","W",
					"W","W","W","W","W","W","W","W",".",".","W",
					"W","W","W",".",".","W","W","W",".",".","W",
					"W","W","W",".",".","W","W","W",".",".",".",
					"W","W","W",".",".","W","W","W",".",".","W",
					"W",".",".",".",".",".",".",".",".",".","W",
					"W",".",".",".",".",".",".",".",".",".","W",
					"W","W","W","W","W",".","W","W","W","W","W",
					"W","W","W","W","W",".","W","W","W","W","W"],
					
					# Last room of this category; no comma
				   ["W","W","W","W","W",".","W","W","W","W","W",
					"W","W",".",".",".",".","W",".",".",".","W",
					"W","W",".","W","W","W","W",".",".",".","W",
					"W",".",".",".","W",".",".",".",".",".","W",
					"W",".",".",".","W",".",".",".",".",".","W",
					"W",".",".",".","W",".",".",".",".",".",".",
					"W",".",".",".","W","W","W",".",".",".","W",
					"W",".",".",".",".",".","W","W",".","W","W",
					"W",".",".",".",".",".",".",".",".","W","W",
					"W",".",".",".",".",".","W","W","W","W","W",
					"W","W","W","W","W","W","W","W","W","W","W"]
					
					]; # End bracket
					
	# Fifth type of room. As a reminder, "W" is a wall tile and "." is a floor tile
	var endData = [ # Start bracket
					
					# Follows the same formatting as the other room types
				   ["W","W","W","W","W","W","W","W","W","W","W",
					"W","W","W","W","W","W","W","W","W","W","W",
					"W","W","W","W",".",".",".","W","W","W","W",
					"W",".",".",".",".",".",".",".",".",".","W",
					"W",".",".",".",".",".",".",".",".",".","W",
					"W",".",".",".",".",".",".",".",".",".","W",
					"W","W","W","W","W",".","W","W","W","W","W",
					"W","W",".",".",".",".",".",".",".","W","W",
					"W","W",".",".",".",".",".",".",".","W","W",
					"W","W",".",".",".",".",".",".",".","W","W",
					"W","W","W","W","W",".","W","W","W","W","W"],
					
					# Last room of this category; no comma
				   ["W","W","W","W","W",".","W","W","W","W","W",
					"W","W","W",".",".",".",".",".","W","W","W",
					"W",".",".",".",".",".",".",".",".",".","W",
					"W",".",".",".",".",".",".",".",".",".","W",
					"W","W",".",".",".",".",".",".",".","W","W",
					"W","W",".",".",".",".",".",".",".","W","W",
					"W",".",".",".",".",".",".",".",".",".","W",
					"W",".",".",".",".",".",".",".",".",".","W",
					"W","W","W",".",".",".",".",".","W","W","W",
					"W","W","W","W",".",".",".","W","W","W","W",
					"W","W","W","W","W","W","W","W","W","W","W"]
					
					]; # End bracket
	
	# Level map is an array itself: Formatted as [Center, T-Inter, Linear, Corner, Dead End]
	levelMap = [centerData,interData,linearData,cornerData,endData];
	# Returns the entire map
	return levelMap;
	
# This function literally just returns an 11x11 box full of walls
func blank_room():
	# Nothing more, nothing less
	return ["W","W","W","W","W","W","W","W","W","W","W",
			"W","W","W","W","W","W","W","W","W","W","W",
			"W","W","W","W","W","W","W","W","W","W","W",
			"W","W","W","W","W","W","W","W","W","W","W",
			"W","W","W","W","W","W","W","W","W","W","W",
			"W","W","W","W","W","W","W","W","W","W","W",
			"W","W","W","W","W","W","W","W","W","W","W",
			"W","W","W","W","W","W","W","W","W","W","W",
			"W","W","W","W","W","W","W","W","W","W","W",
			"W","W","W","W","W","W","W","W","W","W","W",
			"W","W","W","W","W","W","W","W","W","W","W"];

# Rotates a map 90 degrees clockwise
func rotate_map(arr,size):
	# arr is a 1D array, but will get converted to a 2D array
	# size is the size of the room; should be a single value because all rooms are square
	
	# Yes, I know this is scuffed, shut up
	var arr2D = [];
	# Initialize 2D array
	for k in size:
		# Add an empty array for each entry in the first dimension
		arr2D.append([]);
		# Go to second layer so we can initialize a default value
		for l in size:
			# Initialize the value
			arr2D[k].append(null);
	# Track index
	var index = 0;
	# Loop through array
	for k in arr:
		# Determine coord
		var coord = index_to_coord(index,size);
		# Write value to 2D array
		arr2D[coord[1]][coord[0]] = k;
		# Increment index
		index += 1;
		
	# N and M are the same in this case due to being square
	# And the input is just the converted array above
	var input = arr2D;
	var n = size;
	var m = size;
	
	# Fill 2D array the same way we did for arr2D (it's really annoying that I have to do this, by the way)
	var output = [];
	for i in n:
		output.append([])
		for j in m:
			output[i].append(null);
		
	# This is a classic matrix rotation script
	for i in n:
		for j in m:
			output [j][n-1-i] = input[i][j];
			
	# Convert the final product back into a 1D array
	var finalArr = [];
	# Loop through output
	for k in output:
		for l in k:
			finalArr.append(l);
			
	# Return line. As a reminder, finalArr is a 1D array
	return finalArr;

# Converts a 1D index into a 2D coordinate array
func index_to_coord(index,width):
	# Continuation of scuffed function above
	# X coordinate
	var X = index % width;
	# Y coordinate
	var Y = floor(index / width);
	# Return line
	return [X,Y];
