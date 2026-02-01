extends State

func _ready() -> void:
	state_id = State_ID.CHARGEFORWARD

func enter(previous_state: State_ID = 0) -> void:
	animation_player.play("Proto-Run")
	animation_player.seek(0.2)
	PlayerConstants.GROUND_DRAG = PlayerConstants.GROUND_DRAG_CHARGE_FORWARD_CONST
	PlayerConstants.GROUND_DRAG_DEGREE = PlayerConstants.GROUND_DRAG_CHARGE_FORWARD_DEGREE_CONST
func exit() -> void:
	PlayerConstants.GROUND_DRAG_DEGREE = PlayerConstants.GROUND_DRAG_DEGREE_CONST
	PlayerConstants.GROUND_DRAG = PlayerConstants.GROUND_DRAG_CONST

func physics_update(delta: float) -> void:
	var input_vector = get_input_vector()
	
	if input_vector.x != 0:
		physics_body.get_node("Sprite2D").scale.x = -1 if input_vector.x > 0 else 1
	
	if input_vector.x != 0:
		physics_body.velocity.x += input_vector.x * PlayerConstants.GROUND_ACCEL * delta
	
	print("charging_velocity: ", physics_body.velocity)
	
	if handle_leap_and_squat():
		return
	
	if handle_wind_up():
		return
		
	if input_vector.x == 0 and physics_body.velocity.x != 0:
		change_state(State_ID.SLIDING)
		return

	if physics_body.velocity.length() == 0:
		change_state(State_ID.IDLE)
		return
	
	if not physics_body.is_on_floor():
		change_state(State_ID.FALLING)
		return
		
func can_enter_from(other_state : State_ID) -> bool:
	return false
	
