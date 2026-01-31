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
	
	if is_jump_just_pressed():
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
