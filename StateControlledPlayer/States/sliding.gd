extends State



func _ready() -> void:
	state_id = State_ID.SLIDING

func enter(previous_state: State_ID = 0) -> void:
	animation_player.play("Proto-Idle")
	PlayerConstants.GROUND_DRAG_DEGREE = PlayerConstants.GROUND_DRAG_SLIDING_DEGREE_CONST
	PlayerConstants.GROUND_DRAG = PlayerConstants.GROUND_DRAG_SLIDING_CONST
func exit() -> void:
	PlayerConstants.GROUND_DRAG_DEGREE = PlayerConstants.GROUND_DRAG_DEGREE_CONST
	PlayerConstants.GROUND_DRAG = PlayerConstants.GROUND_DRAG_CONST

func physics_update(delta: float) -> void:
	var input_vector = get_input_vector()

	#if Input.is_action_just_pressed("s"):
	#	change_state(State_ID.QUADSTOMP)
	#	return

	if  physics_body.is_on_floor():
		if(physics_body.check_jump_tap()):
			change_state(State_ID.LEAPING)
			physics_body.jump_tap = PlayerConstants.JUMP_TAP_TIME
			return
		elif (physics_body.jump_tap <= 0) and Input.is_action_pressed("jump"):
			change_state(State_ID.SQUAT)
			physics_body.jump_tap = PlayerConstants.JUMP_TAP_TIME
			return
		
		
	if handle_wind_up():
		return

	if input_vector.x != 0 and physics_body.is_on_floor():
		change_state(State_ID.RUNNING)
		return

	if abs(physics_body.velocity.x) < PlayerConstants.MIN_HORIZONTAL_SPEED:
		physics_body.velocity.x = 0
		change_state(State_ID.IDLE)
		return
	
	# redudant?
	if physics_body.velocity.length() == 0:
		change_state(State_ID.IDLE)
		return

	if not physics_body.is_on_floor():
		change_state(State_ID.FALLING)
		return
		
func can_enter_from(other_state : State_ID) -> bool:
	return false
