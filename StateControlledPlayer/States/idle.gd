extends State


func _ready() -> void:
	state_id  = State_ID.IDLE

func enter(previous_state: State_ID = 0) -> void:
	animation_player.play("Proto-Idle")
	physics_body.velocity.x = 0

func physics_update(delta: float) -> void:
	var input_vector = get_input_vector()
	
	if Input.is_action_just_pressed("s"):
		change_state(State_ID.QUADSTOMP)
		return
	
	if physics_body.is_on_floor():
		print("is_action_jump_released: ", Input.is_action_just_released("jump"))
		if(physics_body.check_jump_tap()):
			change_state(State_ID.LEAPING)
			return
		elif (physics_body.jump_tap <= 0) and Input.is_action_pressed("jump"):
			change_state(State_ID.SQUAT)
			return
		

	if input_vector.x != 0 and physics_body.is_on_floor():
		change_state(State_ID.RUNNING)
		return

	if not physics_body.is_on_floor():
		change_state(State_ID.FALLING)
		return
		
func can_enter_from(other_state : State_ID) -> bool:
	return false
