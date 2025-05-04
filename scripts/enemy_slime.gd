extends CharacterBody2D

const MAX_SPEED = 100
const PULL_FORCE = 25000
var move_direction = -1
	
func _physics_process(delta):
	# Check if the enemy slime is on a surface. If so, set rotation to angle of 
	# surface normal and move based on it's rotation. Else, try to pull it back
	# onto the surface
	if is_on_wall():
		rotation = get_wall_normal().angle() + (PI/2)
		velocity = transform.x * move_direction * MAX_SPEED
	else:
		velocity = transform.y * PULL_FORCE * delta
	move_and_slide()
	
	# Prevent enemy slime from leaving world boundaries
	position.x = clamp(position.x, 6, 634)
	position.y = clamp(position.y, 0, 365)
	
	# If the enemy slime reaches world boundaries, reverse its direction
	if (position.x == 6 || position.x == 634 || position.y == 0 || position.y == 365):
		move_direction *= -1


# If player slime touches enemy slime, kill them and reset level
func _on_area_2d_body_entered(body):
	if body.name == "Slime":
		get_tree().reload_current_scene()
	#get_tree().reload_current_scene()
