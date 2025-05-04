extends CharacterBody2D

# Constants & Variables
const MAX_SPEED = 150
const JUMP_FORCE = -300
const PULL_FORCE = 50000
const COYOTE_TIME = 6
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var gravity_direction = ProjectSettings.get_setting("physics/2d/default_gravity_vector")
var wants_to_jump = false
var jumping = false
var moving = [false, 0]
var air_time = 0
var has_key = false
var can_play = false
var end_pos = Vector2.ZERO

# Signals
signal interacting

# When user enters any valid input during playtime, find it and set according action response
func _unhandled_input(event : InputEvent):
	if can_play:
		var input_x = Input.get_axis("move_left", "move_right")
		if input_x != 0:
			moving = [true, input_x]
		else:
			moving[0] = false
		
		if Input.is_action_just_pressed("jump") && air_time < COYOTE_TIME:
			wants_to_jump = true
		else:
			wants_to_jump = false
		
		# Send interacting signal & await response, if any
		if Input.is_action_pressed("interact"):
			emit_signal("interacting")
		
		# Reset current level
		if Input.is_action_pressed("reset"):
			get_tree().reload_current_scene()
		
		# Quit game
		if Input.is_action_pressed("pause"):
			get_tree().quit()
	
func _physics_process(delta):
	if can_play:
		if is_on_wall():
			# While user is on a surface, rotate them based on the surface normal while resetting 
			# air time & jump check
			rotation = get_wall_normal().angle() + (PI/2)
			jumping = false
			air_time = 0
			
			# If the user inputted left/right, move in said direction based off their rotation
			# Else, stop movement
			if moving[0]:
				var move_direction = transform.x * moving[1]
				velocity = move_direction * MAX_SPEED
			else:
				velocity = Vector2.ZERO
			
			# If user inputted a jump while on a surface, set jump check & jump based off rotation
			if wants_to_jump:
				jumping = true
				velocity = transform.y * JUMP_FORCE
				
		else:
			# If user is not on a wall, check if they were jumping or not. If not jumping, pull them
			# back to prior surface based on rotation. Else, they jumped, so set normal gravity
			# while resetting rotation
			if !jumping:
				gravity_direction = transform.y * PULL_FORCE
			else:
				rotation = 0
				gravity_direction = ProjectSettings.get_setting("physics/2d/default_gravity_vector") * gravity
			# add air time leway to make jumps more forgiving
			air_time += 1
			
			# While in the air and wanting to move, let them move, slowing them down if speed 
			# exceeds speed cap else putting them at speed cap. If they stop moving in the air, slow
			# them to a halt but not instantly
			if moving[0]:
				if(velocity.x > MAX_SPEED):
					velocity.x = move_toward(velocity.x, MAX_SPEED * moving[1], MAX_SPEED/5)
				else:
					velocity.x = MAX_SPEED * moving[1]
			else:
				velocity.x = move_toward(velocity.x, 0, MAX_SPEED/5) #MAX_SPEED/5

			# Add gravity based on jump check, making sure not to exceed gravity pull
			velocity += gravity_direction * delta
			if velocity.y > gravity:
				velocity.y = gravity
		
	else:
		# Since user isn't playable yet, check if it's due to finishing the level or not. If at the 
		# end of the level (vector != 0,0), then move them to door's position & rotation
		if end_pos != Vector2.ZERO:
			position.x = move_toward(position.x, end_pos.x, 1)
			position.y = move_toward(position.y, end_pos.y, 1)
			rotation = get_wall_normal().angle() + (PI/2)

	move_and_slide()
	
	# ensure user can't move offscreen except bottom (where death boundary is)
	position.x = clamp(position.x, 6, 634)
	position.y = clamp(position.y, 0, 1000)

# Once level transition is finished, allow the user to play
func _on_transition_layer_start_level():
	can_play = true

# When user is opening the door with the key, stop inputs & current movement & 
# get door's position
func _on_exit_door_opening(door_pos):
	can_play = false
	velocity = Vector2.ZERO
	end_pos = door_pos

# When doors are closing, hide player
func _on_exit_door_closing():
	visible = false
