extends State

func _ready() -> void:
	state_id = State_ID.FALLING
	
func enter(previous_state: State_ID = 0) -> void:
	animation_player.play("Proto-Fall")

func physics_update(delta: float) -> void:
	var input_vector = get_input_vector()
	
	if input_vector.x != 0:
		physics_body.get_node("Sprite2D").scale.x = -1 if input_vector.x > 0 else 1
	
	if input_vector.x != 0:
		physics_body.velocity.x += input_vector.x * PlayerConstants.AIR_ACCEL * delta
	
	if physics_body.is_on_floor():
		
		
		physics_body.vfx_player.play("SmallGroundedImpact")
		physics_body.detach_vfx_sprite()

		if physics_body.velocity.length() == 0:
			change_state(State_ID.IDLE)
		elif input_vector.x == 0 and physics_body.velocity.x != 0:
			change_state(State_ID.SLIDING)
		elif physics_body.velocity.x != 0:
			change_state(State_ID.RUNNING)
		return
		
func can_enter_from(other_state : State_ID) -> bool:
	return false
