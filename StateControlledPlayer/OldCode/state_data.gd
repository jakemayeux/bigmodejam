extends Node2D
#bit masks for current state
enum State{
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
	ALL = 		0b1111111111111
}
#bit set to describe which state each state can transition too
enum StateTransitions{
	IDLE_TRANS = 		State.IDLE | State.RUNNING | State.FALLING | State.DIVING | State.RISING | State.LEAPING | State.QUADSTOMP,
	RUNNING_TRANS = 	State.IDLE | State.RUNNING | State.FALLING | State.DIVING | State.LEAPING | State.SLIDING | State.QUADSTOMP,
	FALLING_TRANS = 	State.IDLE | State.RUNNING | State.FALLING | State.DIVING | State.SLIDING ,
	RISING_TRANS = 	 	State.IDLE | State.RUNNING | State.FALLING | State.DIVING | State.RISING,
	DIVING_TRANS = 	 	State.IDLE | State.RUNNING | State.FALLING | State.DIVING,
	LEAPING_TRANS = 	State.IDLE | State.RUNNING | State.FALLING | State.DIVING | State.SLIDING,
	ROLLING_TRANS =  	State.IDLE | State.RUNNING | State.FALLING | State.DIVING,
	SLIDING_TRANS =		State.IDLE | State.RUNNING | State.FALLING | State.DIVING | State.RISING | State.LEAPING | State.SLIDING | State.QUADSTOMP,
	QUADSTOMP_TRANS = 	State.RUNNING | State.DIVING  | State.LEAPING | State.RISING,
	SQUAT_TRANS = 		State.RISING
}
var stateTransitionTable := {}
var stateInteruptTable := {}
func _init() -> void:
	#table to convert state bitmask to transitionable states
	stateTransitionTable = {
		State.IDLE : StateTransitions.IDLE_TRANS,
		State.RUNNING : StateTransitions.RUNNING_TRANS,
		State.FALLING : StateTransitions.FALLING_TRANS,
		State.RISING : StateTransitions.RISING_TRANS,
		State.DIVING : StateTransitions.DIVING_TRANS,
		State.LEAPING : StateTransitions.LEAPING_TRANS,
		State.ROLLING : StateTransitions.ROLLING_TRANS,
		State.SLIDING : StateTransitions.SLIDING_TRANS,
		State.QUADSTOMP : StateTransitions.QUADSTOMP_TRANS,
		State.SQUAT :   StateTransitions.SQUAT_TRANS
	}
	#table to convert state bitmask to animations which can interupt it
	stateInteruptTable = {
		State.IDLE : State.ALL & (~State.IDLE),
		State.RUNNING : State.ALL & (~State.RUNNING),
		State.FALLING : State.ALL & (~State.FALLING),
		State.RISING : State.ALL & (~State.RISING),
		State.DIVING : State.ALL & (~State.DIVING),
		State.LEAPING : State.ALL & (~State.LEAPING) & (~State.RUNNING) & (~State.SLIDING),
		State.ROLLING : State.ALL & (~State.ROLLING),
		State.SLIDING : State.ALL & (~State.SLIDING),
		State.QUADSTOMP : State.NONE | (State.LEAPING),
		State.SQUAT : State.RISING
	}
