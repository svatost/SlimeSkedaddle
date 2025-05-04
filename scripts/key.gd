extends Area2D

# When slime enters grabbable area, hide key and set their key variable to true
func _on_body_entered(body):
	if visible:
		body.has_key = true
		visible = false
