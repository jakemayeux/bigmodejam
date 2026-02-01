extends State

var can_dive:bool = true

func _ready() -> void:
	state_id = State_ID.DIVING
	
func enter(previous_state: State_ID = 0) -> void:
	animation_player.play("Proto-Dive")
	physics_body.velocity.x += PlayerConstants.DIVE_VELOCITY *  physics_body.get_node("Sprite2D").scale.x * -1
	can_dive = false

func physics_update(delta: float) -> void:
	var input_vector = get_input_vector()
	
	if input_vector.x != 0:
		physics_body.get_node("Sprite2D").scale.x = -1 if input_vector.x > 0 else 1
	
	if input_vector.x != 0:
		physics_body.velocity.x += input_vector.x * PlayerConstants.AIR_ACCEL * delta
	
	if physics_body.is_on_floor():
		can_dive = true
		physics_body.vfx_player.play("SmallGroundedImpact")
		physics_body.detach_vfx_sprite()
		
		change_state(State_ID.ROLLING)

		
	var horizontal_dominates = sqrt(abs(physics_body.velocity.y)) <= abs(physics_body.velocity.x)
	if not horizontal_dominates:
		if(physics_body.velocity.y > 0):
			change_state(State_ID.FALLING)
		
func can_enter_from(other_state : State_ID) -> bool:
	return false
