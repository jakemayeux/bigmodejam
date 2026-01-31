extends CharacterBody2D



@onready var state_machine: StateMachine = $StateMachine
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

var jump_buffer_time := 0.075
var jump_buffer := 0.0

var stored_stomp_velocity := 0.0
var stored_crouch_velocity := 0.0

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	_update_jump_buffer(delta)
	
	_apply_gravity_and_drag(delta)
	
	move_and_slide()

func _update_jump_buffer(delta: float) -> void:
	if Input.is_action_pressed("jump"):
		jump_buffer = jump_buffer_time
	elif jump_buffer > 0:
		jump_buffer -= delta

func _apply_gravity_and_drag(delta: float) -> void:
	if not is_on_floor():
		if velocity.length() > 0:
			velocity -= PlayerConstants.AIR_DRAG * pow(velocity.length(), PlayerConstants.AIR_DRAG_DEGREE) * velocity.normalized() * delta
		velocity += get_gravity() * PlayerConstants.GRAVITY_MODIFIER * delta
	else:
		if velocity.length() > 0:
			velocity -= PlayerConstants.GROUND_DRAG * pow(velocity.length(), PlayerConstants.GROUND_DRAG_DEGREE) * velocity.normalized() * delta

func get_current_state() -> State.State_ID:
	return state_machine.current_state

func change_state(new_state: State.State_ID) -> void:
	state_machine.change_state(new_state)
