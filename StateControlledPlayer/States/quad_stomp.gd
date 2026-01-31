extends State

func _ready() -> void:
	state_id = State_ID.QUADSTOMP

func exit() -> void:
	pass

func enter(previous_state: State_ID = 0) -> void:
	animation_player.play("Proto-QuadStomp")

func physics_update(delta: float) -> void:
	physics_body.stored_stomp_velocity += (physics_body.velocity - physics_body.velocity.move_toward(Vector2.ZERO, PlayerConstants.STOMP_STOMP_SPEED * delta)).length()
	
	physics_body.velocity = physics_body.velocity.move_toward(Vector2.ZERO, PlayerConstants.STOMP_STOMP_SPEED * delta)
	
	
	if not animation_player.is_playing() or 0.5 < (animation_player.current_animation_position/animation_player.current_animation_length):
		if physics_body.jump_buffer > 0:
			if(Input.get_axis("a","d") != 0):
				change_state(State_ID.LEAPING)
			else:
				change_state(State_ID.SQUAT)
		return

func can_enter_from(other_state : State_ID) -> bool:
	return false
