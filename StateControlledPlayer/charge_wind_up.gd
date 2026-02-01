extends State


func _ready() -> void:
	state_id = State_ID.CHARGEWINDUP

func exit() -> void:
	pass

func enter(previous_state: State_ID = 0) -> void:
	animation_player.play("Proto-ChargeWind")

func physics_update(delta: float) -> void:
	#physics_body.stored_stomp_velocity += (physics_body.velocity - physics_body.velocity.move_toward(Vector2.ZERO, PlayerConstants.STOMP_STOMP_SPEED * delta)).length()
	
	physics_body.velocity = physics_body.velocity.move_toward(Vector2.ZERO, PlayerConstants.STOMP_STOMP_SPEED * delta)
	
	
	if physics_body.check_movement_action_hold() and not animation_player.is_playing():
			change_state(State_ID.CHARGEWINDHOLD)
	elif not Input.is_action_pressed("MovmentAction"):
		#physics_body.velocity.x = PlayerConstants.CHARGE_WIND_UP_VELOCITY_0*physics_body.get_node("Sprite2D").scale.x*-1
		change_state(State_ID.SLIDING)
	return

func can_enter_from(other_state : State_ID) -> bool:
	return false
