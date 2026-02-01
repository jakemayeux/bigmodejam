extends CharacterBody2D



@onready var state_machine: StateMachine = $StateMachine
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var vfx_parent: Node2D = $VisualEffects
@onready var vfx_player: AnimationPlayer = vfx_parent.get_node("AnimationPlayer")



var jump_buffer := -1.0

var jump_tap = -1.0
var is_jump_tap:bool = false

var stored_stomp_velocity := 0.0
var stored_crouch_velocity := 0.0

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	_update_jump_buffer(delta)
	
	_apply_gravity_and_drag(delta)
	
	move_and_slide()

func _update_jump_buffer(delta: float) -> void:
	print("jump_tap: ", jump_tap)
	print("is_jump_tap: ", is_jump_tap)
	print("jump_buffer: ", jump_buffer)
	if Input.is_action_just_pressed("jump"):
		jump_buffer = PlayerConstants.JUMP_BUFFER_TIME
		jump_tap = PlayerConstants.JUMP_TAP_TIME
	else:
		if jump_buffer > 0:
			jump_buffer -= delta
		if jump_tap > 0:	
			jump_tap -= delta
	if Input.is_action_just_released("jump") and (jump_tap >= 0):
		is_jump_tap = true
		
func check_jump_tap()-> bool:
	var ret_bool = is_jump_tap
	is_jump_tap = false 
	return ret_bool and (jump_tap > 0)
	

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

func detach_vfx_sprite() -> void:
	var gp : Vector2 = vfx_parent.global_position
	vfx_parent.top_level = true
	vfx_parent.global_position = gp
	
func _on_vfx_animation_player_animation_finished(anim_name: StringName) -> void:
	vfx_player.play("None")
	vfx_parent.top_level = false
	vfx_parent.position = Vector2(0,0)
