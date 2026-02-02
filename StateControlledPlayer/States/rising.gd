extends State

func _ready() -> void:
	state_id = State_ID.RISING
	
func enter(previous_state: State_ID = 0) -> void:
	animation_player.play("Proto-Rise")
	
	physics_body.velocity.y = PlayerConstants.JUMP_VELOCITY
	physics_body.velocity += Vector2.UP * physics_body.stored_stomp_velocity
	physics_body.velocity += Vector2.UP * physics_body.stored_crouch_velocity
	
	physics_body.stored_stomp_velocity = 0
	physics_body.stored_crouch_velocity = 0
	
func exit() -> void:
	#proably redudant, just incase
	physics_body.stored_stomp_velocity = 0
	physics_body.stored_crouch_velocity = 0

func physics_update(delta: float) -> void:
	var input_vector = get_input_vector()
	
	if input_vector.x != 0:
		physics_body.get_node("Sprite2D").scale.x = -1 if input_vector.x > 0 else 1
	
	if input_vector.x != 0:
		physics_body.velocity.x += input_vector.x * PlayerConstants.AIR_ACCEL * delta
	
	if handle_dive():
		return
	
	# Transition to falling when moving downward
	if physics_body.velocity.y > 0:
		change_state(State_ID.FALLING)
		return
	
	# Check if landed (shouldn't happen while rising, but just in case)
	if physics_body.is_on_floor():
		if physics_body.velocity.x != 0:
			change_state(State_ID.RUNNING)
		else:
			change_state(State_ID.IDLE)
		return
		
func can_enter_from(other_state : State_ID) -> bool:
	return false
