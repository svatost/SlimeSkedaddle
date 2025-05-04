extends Area2D

@onready var animations = $AnimatedSprite2D
var can_be_opened = false
signal opening(door_pos)
signal closing

# When slime enters door radius, check if they have the key. If so, allow them 
# to exit level
func _on_body_entered(body):
	if body.has_key:
		can_be_opened = true

# When slime leaves door radius, if they had the key prior to leaving, prevent 
# them from leaving
func _on_body_exited(body):
	if body.has_key:
		can_be_opened = false

# If slime uses interact button when within door radius, check if they can 
# leave. If so, play opening animation & notify slime that they're leaving
# level, along with door coords and prevent user from interacting with it again
func _on_slime_interacting():
	if can_be_opened:
		animations.play("Open")
		emit_signal("opening", position)
		can_be_opened = false

# When door is finished opening, play opening animation in reverse, notify other
# elements that it is closing
func _on_animated_sprite_2d_animation_finished():
	if animations.animation == "Open":
		emit_signal("closing")
		animations.play("Open", -1)
