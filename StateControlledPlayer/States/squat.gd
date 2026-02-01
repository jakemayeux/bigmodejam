extends State

func _ready() -> void:
	state_id = State_ID.SQUAT

func enter(previous_state: State_ID = 0) -> void:
	animation_player.play("Proto-SquatJump")
	physics_body.jump_buffer = 0

func physics_update(delta: float) -> void:
	
	physics_body.stored_stomp_velocity += (physics_body.velocity - physics_body.velocity.move_toward(Vector2.ZERO, PlayerConstants.STOMP_STOMP_SPEED * delta)).length()
	physics_body.stored_crouch_velocity += PlayerConstants.CROUCH_STORED_VELOCITY_GROWTH * delta
	physics_body.stored_crouch_velocity = min(physics_body.stored_crouch_velocity, PlayerConstants.CROUCH_STORED_VELOCITY_MAX_BONUS)
	
	
	physics_body.velocity = physics_body.velocity.move_toward(Vector2.ZERO, 500.0 * delta)
	
	
	if is_jump_just_released():
		change_state(State_ID.RISING)
		return

func exit() -> void:
	
	pass
	
func can_enter_from(other_state : State_ID) -> bool:
	return false
