extends CharacterBody2D

@onready var state_machine: StateMachine = $StateMachine
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var vfx_parent: Node2D = $VisualEffects
@onready var vfx_player: AnimationPlayer = vfx_parent.get_node("AnimationPlayer")
@onready var jump_audio: AudioStreamPlayer2D = $AudioStreamPlayer2D_Jump
@onready var land_audio: AudioStreamPlayer2D = $AudioStreamPlayer2D_Land
@onready var footstep_audio: AudioStreamPlayer2D = $AudioStreamPlayer2D_Footstep

# Footstep sound array - add your footstep file paths here
var footstep_sounds = [
	"res://SFX/Footstep1.wav",
	"res://SFX/Footstep2.wav",
	"res://SFX/Footstep3.wav",
	"res://SFX/Footstep4.wav"
	# Add more footstep sounds here...
]

var jump_buffer := -1.0
var jump_tap = -1.0
var is_jump_tap:bool = false
var was_on_floor_last_frame := false

var movement_action_buffer := -1.0
var movement_action_tap := -1.0
var is_movement_action_tap : bool = false

var stored_stomp_velocity := 0.0
var stored_crouch_velocity := 0.0

func _ready() -> void:
	if jump_audio == null:
		print("Warning: AudioStreamPlayer2D_Jump node not found!")
		# Try to find it with different naming patterns
		if has_node("AudioStreamPlayer2D_Jump"):
			jump_audio = $AudioStreamPlayer2D_Jump
		elif has_node("AudioStreamPlayer2D_Running/AudioStreamPlayer2D_Jump"):
			jump_audio = $AudioStreamPlayer2D_Running/AudioStreamPlayer2D_Jump
		elif has_node("AudioStreamPlayer2D"):
			jump_audio = $AudioStreamPlayer2D
		else:
			print("No jump audio node found!")
			
	if land_audio == null:
		print("Warning: AudioStreamPlayer2D_Land node not found!")
		# Try to find it with different naming patterns
		if has_node("AudioStreamPlayer2D_Land"):
			land_audio = $AudioStreamPlayer2D_Land
		elif has_node("AudioStreamPlayer2D_Running/AudioStreamPlayer2D_Land"):
			land_audio = $AudioStreamPlayer2D_Running/AudioStreamPlayer2D_Land
		else:
			print("No land audio node found!")
			
	if footstep_audio == null:
		print("Warning: AudioStreamPlayer2D_Footstep node not found!")
		if has_node("AudioStreamPlayer2D_Footstep"):
			footstep_audio = $AudioStreamPlayer2D_Footstep
		else:
			print("No footstep audio node found!")

func _physics_process(delta: float) -> void:
	_update_jump_buffer(delta)
	_update_accel()
	_update_movement_action_buffer(delta)
	
	_apply_gravity_and_drag(delta)
	
	# Check for jump trigger (when leaving the ground)
	_check_and_play_jump_sound()
	
	# Check for landing trigger (when hitting the ground)
	_check_and_play_land_sound()
	
	was_on_floor_last_frame = is_on_floor()
	
	move_and_slide()

func _check_and_play_jump_sound() -> void:
	# Play jump sound when we just left the ground (was on floor last frame, now not on floor)
	# AND we have upward velocity (indicating a jump)
	if was_on_floor_last_frame and not is_on_floor() and velocity.y < 0:
		if jump_audio != null:
			jump_audio.play()
		else:
			print("Jump audio node is null!")

func _check_and_play_land_sound() -> void:
	# Play land sound when we just hit the ground (was not on floor last frame, now on floor)
	# AND we have downward velocity (indicating a fall)
	if not was_on_floor_last_frame and is_on_floor() and velocity.y >= 0:
		if land_audio != null:
			land_audio.play()
		else:
			print("Land audio node is null!")

func play_random_footstep() -> void:
	# Play a random footstep sound
	if footstep_audio != null and footstep_sounds.size() > 0:
		# Pick a random footstep sound
		var random_index = randi() % footstep_sounds.size()
		var footstep_sound = load(footstep_sounds[random_index])
		
		# Load and play the random sound
		if footstep_sound != null:
			footstep_audio.stream = footstep_sound
			footstep_audio.play()
		else:
			print("Failed to load footstep sound: ", footstep_sounds[random_index])
	else:
		print("Footstep audio node is null or no footstep sounds available!")

#----------------Jump_Buffer-----------------------
func _update_jump_buffer(delta: float) -> void:
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
func check_jump_hold()->bool:
	return (jump_tap <= 0) and Input.is_action_pressed("jump")
	
#----------------Movement_Action(shift)-----------------------
func _update_movement_action_buffer(delta:float)->void:
	if Input.is_action_just_pressed("MovmentAction"):
		movement_action_buffer = PlayerConstants.JUMP_BUFFER_TIME
		movement_action_tap = PlayerConstants.JUMP_TAP_TIME
	else:
		if movement_action_buffer > 0:
			movement_action_buffer -= delta
		if movement_action_tap > 0:	
			movement_action_tap -= delta
	if Input.is_action_just_released("MovmentAction") and (movement_action_tap >= 0):
		is_movement_action_tap = true
func check_movement_action_buffer() -> bool:
	return movement_action_buffer > 0
func check_movement_action_tap()-> bool:
	var ret_bool = is_movement_action_tap
	is_movement_action_tap = false 
	return ret_bool and (movement_action_tap > 0)
func check_movement_action_hold()->bool:
	return (movement_action_tap <= 0) and Input.is_action_pressed("MovmentAction")

func _update_accel()->void:
	PlayerConstants.GROUND_ACCEL = PlayerConstants.GROUND_DRAG * pow(PlayerConstants.MAX_SPEED, PlayerConstants.GROUND_DRAG_DEGREE)
	PlayerConstants.AIR_ACCEL = PlayerConstants.AIR_DRAG * pow(PlayerConstants.MAX_AIR_SPEED, PlayerConstants.AIR_DRAG_DEGREE)

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
