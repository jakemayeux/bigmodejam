extends State



func _ready() -> void:
	state_id = State_ID.ROLLING

func enter(previous_state: State_ID = 0) -> void:
	animation_player.play("Proto-Roll")
	PlayerConstants.GROUND_DRAG = PlayerConstants.GROUND_DRAG_RUNNING_CONST
func exit() -> void:
	PlayerConstants.GROUND_DRAG_DEGREE = PlayerConstants.GROUND_DRAG_DEGREE_CONST
	PlayerConstants.GROUND_DRAG = PlayerConstants.GROUND_DRAG_CONST

func physics_update(delta: float) -> void:
	var input_vector = get_input_vector()

	if  physics_body.is_on_floor() and not animation_player.is_playing():
		change_state(State_ID.SLIDING)
		
func can_enter_from(other_state : State_ID) -> bool:
	return false
