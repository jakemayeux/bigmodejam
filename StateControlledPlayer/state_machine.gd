class_name StateMachine extends Node

signal state_changed(previous_state: State, new_state: State)

var states : Dictionary = {}
var current_state : State.State_ID = State.State_ID.IDLE

var animation_player : AnimationPlayer
var physics_body : CharacterBody2D

func _ready() -> void:
	await owner.ready
	animation_player = owner.get_node("AnimationPlayer")
	physics_body = owner
	for child in get_children():
		if child is State:
			if (child.state_id != -1):
				child.animation_player = animation_player
				child.physics_body = physics_body
				child.state_finished.connect(state_finished)
				states[child.state_id] = child
	if states.size() != 0:
		change_state(State.State_ID.IDLE)		
			
			
func _process(delta: float) -> void:
	for state in states: #purely for animation interupts, not in use rn
		if(states[state].can_enter_from(current_state)):
			change_state(state)
			break
	get_current_state().update(delta)
	
func _physics_process(delta: float) -> void:
	get_current_state().physics_update(delta)

func _unhandled_input(event: InputEvent) -> void:
	get_current_state().handle_input(event)

func change_state(new_current_state : State.State_ID) -> void:
	
	if(current_state & new_current_state):
		if(not get_current_state().can_interupt_self()):
			return
	get_current_state().exit()
	
	states[new_current_state].enter(current_state)
	
	state_changed.emit(current_state,new_current_state)
	
	current_state = new_current_state

func get_current_state() -> State:
	return states.get(current_state,null)
	
func state_finished(next_state : State.State_ID) -> void:
	change_state(next_state)
