extends Area2D

# If slime falls off of level, kill them & reset level
func _on_body_entered(_body):
	get_tree().reload_current_scene()
