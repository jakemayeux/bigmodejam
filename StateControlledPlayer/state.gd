extends Node
class_name State

enum State_ID {
	NONE = 0,
	IDLE = 		0b0000000000001,
	RUNNING = 	0b0000000000010,
	FALLING = 	0b0000000000100,
	RISING = 	0b0000000001000,
	DIVING = 	0b0000000010000,
	LEAPING = 	0b0000000100000,
	ROLLING = 	0b0000001000000,
	SLIDING =	0b0000010000000,
	QUADSTOMP =	0b0000100000000,
	SQUAT	 =	0b0001000000000,
	CLIMBING =	0b0010000000000,
	CHARGEWINDUP =	\
				0b0100000000000,
	CHARGEWINDHOLD = \
				0b1000000000000,
	CHARGEFORWARD = \
				0b10000000000000,
	ALL = 		0b1111111111111
}

#currently only being used to check if it can interrupt to itself
const interupt_table = {
	State_ID.IDLE : State_ID.ALL & (~State_ID.IDLE),
	State_ID.RUNNING : State_ID.ALL & (~State_ID.RUNNING),
	State_ID.FALLING : State_ID.ALL & (~State_ID.FALLING),
	State_ID.RISING : State_ID.ALL & (~State_ID.RISING),
	State_ID.DIVING : State_ID.ALL & (~State_ID.DIVING),
	State_ID.LEAPING : State_ID.ALL & (~State_ID.LEAPING) & (~State_ID.RUNNING) & (~State_ID.SLIDING),
	State_ID.ROLLING : State_ID.ALL & (~State_ID.ROLLING),
	State_ID.SLIDING : State_ID.ALL & (~State_ID.SLIDING),
	State_ID.QUADSTOMP : State_ID.NONE | (State_ID.LEAPING),
	State_ID.SQUAT : State_ID.RISING,
	State_ID.CLIMBING : State_ID.NONE,
	State_ID.CHARGEWINDUP : State_ID.NONE,
	State_ID.CHARGEWINDHOLD : State_ID.NONE,
	State_ID.CHARGEFORWARD : State_ID.NONE,
}
#not currently in use
enum State_Trans{
	IDLE_TRANS = 		State_ID.IDLE | State_ID.RUNNING | State_ID.FALLING | State_ID.DIVING | State_ID.RISING | State_ID.LEAPING | State_ID.QUADSTOMP,
	RUNNING_TRANS = 	State_ID.IDLE | State_ID.RUNNING | State_ID.FALLING | State_ID.DIVING | State_ID.LEAPING | State_ID.SLIDING | State_ID.QUADSTOMP,
	FALLING_TRANS = 	State_ID.IDLE | State_ID.RUNNING | State_ID.FALLING | State_ID.DIVING | State_ID.SLIDING ,
	RISING_TRANS = 	 	State_ID.IDLE | State_ID.RUNNING | State_ID.FALLING | State_ID.DIVING | State_ID.RISING,
	DIVING_TRANS = 	 	State_ID.IDLE | State_ID.RUNNING | State_ID.FALLING | State_ID.DIVING,
	LEAPING_TRANS = 	State_ID.IDLE | State_ID.RUNNING | State_ID.FALLING | State_ID.DIVING | State_ID.SLIDING,
	ROLLING_TRANS =  	State_ID.IDLE | State_ID.RUNNING | State_ID.FALLING | State_ID.DIVING,
	SLIDING_TRANS =		State_ID.IDLE | State_ID.RUNNING | State_ID.FALLING | State_ID.DIVING | State_ID.RISING | State_ID.LEAPING | State_ID.SLIDING | State_ID.QUADSTOMP,
	QUADSTOMP_TRANS = 	State_ID.RUNNING | State_ID.DIVING  | State_ID.LEAPING | State_ID.RISING,
	SQUAT_TRANS = 		State_ID.RISING,
	CLIMBING_TRANS = 0,
	CHARGEWINDUP_TRANS = 0,
	CHARGEWINDHOLD_TRANS = 0,
	CHARGEFORWARD_TRANS = 0
}
const transition_table = {
		State_ID.IDLE : State_Trans.IDLE_TRANS,
		State_ID.RUNNING : State_Trans.RUNNING_TRANS,
		State_ID.FALLING : State_Trans.FALLING_TRANS,
		State_ID.RISING : State_Trans.RISING_TRANS,
		State_ID.DIVING : State_Trans.DIVING_TRANS,
		State_ID.LEAPING : State_Trans.LEAPING_TRANS,
		State_ID.ROLLING : State_Trans.ROLLING_TRANS,
		State_ID.SLIDING : State_Trans.SLIDING_TRANS,
		State_ID.QUADSTOMP : State_Trans.QUADSTOMP_TRANS,
		State_ID.SQUAT :   State_Trans.SQUAT_TRANS,
		State_ID.CLIMBING :   State_Trans.CLIMBING_TRANS,
		State_ID.CHARGEWINDUP :   State_Trans.CHARGEWINDUP_TRANS,
		State_ID.CHARGEWINDHOLD :   State_Trans.CHARGEWINDHOLD_TRANS,
		State_ID.CHARGEFORWARD :   State_Trans.CHARGEFORWARD_TRANS
}

signal state_finished(next_state : State_ID)

var state_id : State_ID = State_ID.NONE

var physics_body : CharacterBody2D
var animation_player: AnimationPlayer

func can_interupt_self() -> bool:
	return interupt_table.get(state_id, 0) & state_id
func can_interupt_other(other_state : State_ID) -> bool:
	return interupt_table.get(other_state, 0) & state_id
func can_other_interupt(other_state : State_ID) -> bool:
	return interupt_table.get(state_id , 0) & other_state
	
func can_transition_self() -> bool:
	return transition_table.get(state_id, 0) & state_id
func can_transition_to_other(other_state : State_ID) -> bool:
	return transition_table.get(other_state, 0) & state_id
func can_other_transition_to(other_state : State_ID) -> bool:
	return transition_table.get(state_id , 0) & other_state
	
func can_enter_from(other_state : State_ID) -> bool:
	return false

func enter(previous_state: State_ID = 0) -> void:
	pass
	
func exit() -> void:
	pass

func physics_update(delta: float) -> void:
	pass

func update(delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass

func get_input_vector() -> Vector2:
	var input_vector : Vector2 = Vector2.ZERO
	input_vector.x = Input.get_axis("a", "d")
	input_vector.y = Input.get_axis("w", "s")
	return input_vector

func is_jump_pressed() -> bool:
	return Input.is_action_pressed("jump")

func is_jump_just_pressed() -> bool:
	return Input.is_action_just_pressed("jump")

func is_jump_just_released() -> bool:
	return Input.is_action_just_released("jump")

func is_movement_action_just_pressed() -> bool:
	return Input.is_action_just_pressed("MovmentAction")

func change_state(new_state: State_ID) -> void:
	state_finished.emit(new_state)


#--------------------Common State Calls----------------------
func handle_leap_and_squat()-> bool:
	if(physics_body.check_jump_tap()):
		physics_body.change_state(State_ID.LEAPING)
		physics_body.jump_tap = PlayerConstants.JUMP_TAP_TIME
		return true
	elif (physics_body.jump_tap <= 0) and Input.is_action_pressed("jump"):
		change_state(State_ID.SQUAT)
		physics_body.jump_tap = PlayerConstants.JUMP_TAP_TIME
		return true
	return false

func handle_wind_up()-> bool:
	if physics_body.check_movement_action_buffer():
		change_state(State_ID.CHARGEWINDUP)
		return true
	return false

func handle_dive()->bool:
	if physics_body.movement_action_buffer > 0:
		change_state(State_ID.DIVING)
		return true
	return false
		
