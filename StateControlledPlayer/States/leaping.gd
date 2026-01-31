extends State


func _ready() -> void:
	state_id = State_ID.LEAPING

func enter(previous_state: State_ID = 0) -> void:
	animation_player.play("Proto-Leap")
	
	physics_body.velocity.y = PlayerConstants.JUMP_VELOCITY
	
	var input_vector = get_input_vector()
	var temp = input_vector
	temp.y = 0
	
	if temp != Vector2.ZERO:
		physics_body.velocity += temp.normalized() * physics_body.stored_stomp_velocity
	
	physics_body.jump_buffer = 0
	physics_body.stored_stomp_velocity = 0

func physics_update(delta: float) -> void:
	var input_vector = get_input_vector()
	
	if input_vector.x != 0:
		physics_body.get_node("Sprite2D").scale.x = -1 if input_vector.x > 0 else 1
	
	if input_vector.x != 0:
		physics_body.velocity.x += input_vector.x * PlayerConstants.AIR_ACCEL * delta
	
	if physics_body.velocity.y > 0:
		var horizontal_dominates = sqrt(abs(physics_body.velocity.y)) <= abs(physics_body.velocity.x)
		if not horizontal_dominates:
			change_state(State_ID.FALLING)
			return
	
	if physics_body.is_on_floor():
		if input_vector.x == 0 and physics_body.velocity.x != 0:
			change_state(State_ID.SLIDING)
		elif physics_body.velocity.x != 0:
			change_state(State_ID.RUNNING)
		else:
			change_state(State_ID.IDLE)
		return
		
func can_enter_from(other_state : State_ID) -> bool:
	return false
