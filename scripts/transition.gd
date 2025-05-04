extends CanvasLayer

@onready var animations = $AnimationPlayer
signal start_level

# Called when the node enters the scene tree for the first time.
func _ready():
	animations.play("fade_in")

# When fade in/out is complete, either allow player to start playing or either move to next level 
# or end game
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade_in":
		emit_signal("start_level")
	elif anim_name == "fade_out":
		var levelNum = get_tree().get_current_scene().get_name().substr(5).to_int() + 1
		if levelNum < 4:
			var levelName = str("res://scenes/level", levelNum, ".tscn")
			get_tree().change_scene_to_file(levelName)
		else:
			get_tree().quit()


# When key door is closing, fade out
func _on_exit_door_closing():
	animations.play("fade_out")
