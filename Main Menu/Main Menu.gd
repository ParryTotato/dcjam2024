extends Control

# Starts a new game on putton press
func _on_button_new_game_pressed() -> void:
    get_tree(). change_scene_to_file("res://Levels/Level_Test3D.tscn")


# Takes you to the Extracted Heroes Menu Page
func _on_button_extracted_heroes_pressed() -> void:
    pass # Replace with function body.

# Takes you to the options Menu
func _on_button_options_pressed() -> void:
    pass # Replace with function body.

# Quits the Game
func _on_button_quit_pressed() -> void:
    get_tree().quit()
