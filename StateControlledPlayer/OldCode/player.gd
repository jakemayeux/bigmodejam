extends CharacterBody2D


@onready var animationPlayer : AnimationPlayer = $AnimationPlayer

const MAX_SPEED = 300.0
const MIN_HORIZONTAL_SPEED = 20.0;
const MAX_AIR_SPEED = 500.0
const JUMP_VELOCITY = -500.0
const AIR_DRAG = 0.001
const AIR_DRAG_DEGREE = 2 # when 2, air resistance increase quadratically with speed
const GROUND_DRAG = 1
const GROUND_DRAG_DEGREE = 1
const INITAL_STOPPING_DRAG = 0.8
const FINAL_STOPPING_DRAG = 1
const GRAVITYMODIFIER = 2.0
const STOMP_STOMP_SPEED = 500.0
const CROUCH_STORED_VELOCITY_MAX_BONUS = 200.0
const CROUCH_STORED_VELOCITY_GROWTH = 200.0 #growth per second

const GROUND_ACCEL = GROUND_DRAG * pow(MAX_SPEED, GROUND_DRAG_DEGREE)
const AIR_ACCEL = AIR_DRAG * pow(MAX_AIR_SPEED, AIR_DRAG_DEGREE)

var SD = preload("res://StateControlledPlayer//OldCode//state_data.gd").new()

var inputVector : Vector2 = Vector2.ZERO
var inputJump : bool = false
var inputMovementAction : bool = false
var storedStompVelocity = 0;
var storedCrouchVelocity = 0;

var currentState : int = SD.State.IDLE


func process_input() -> void:
	inputVector.x = Input.get_axis("a","d")
	inputVector.y = Input.get_axis("w","s")
	inputJump = Input.is_action_pressed("jump")
	inputMovementAction = Input.is_action_just_pressed("MovmentAction")


var jump_buffer_time := 0.05
var jump_buffer := 0.0

func handle_jump(delta : float) -> void:
	if inputJump:
		jump_buffer = jump_buffer_time
	elif jump_buffer > 0:
		jump_buffer -= delta

	if (jump_buffer > 0) and is_on_floor() and can_state_change(SD.State.LEAPING):
		
		var temp = inputVector
		temp.y = 0
		if(temp != Vector2.ZERO):
			velocity += (temp.normalized()*storedStompVelocity);
		else:
			#velocity += Vector2.UP*storedStompVelocity;
			animationPlayer.play("Proto-SquatJump")
			currentState = SD.State.SQUAT
			jump_buffer = 0
			return
		velocity.y += JUMP_VELOCITY
		storedStompVelocity = 0
		jump_buffer = 0
		currentState = SD.State.LEAPING
		animationPlayer.play("Proto-Leap")
		
		
func handle_input_horizontal(delta : float) -> void:
	if inputVector.x != 0:
		if is_on_floor() and (can_state_change(SD.State.RUNNING) or currentState == SD.State.RUNNING ):
			velocity.x += inputVector.x * GROUND_ACCEL * delta
		else:
			velocity.x += inputVector.x * AIR_ACCEL * delta
	else:
		if (can_state_change(SD.State.IDLE))\
		and abs(velocity.x) < MIN_HORIZONTAL_SPEED:
			velocity.x = 0;
func handle_quad_stomp(delta : float) -> void:
	print ("quad able:", can_state_change(SD.State.QUADSTOMP))
	print ("currentState:", currentState)
	print ("movmentAction:", inputMovementAction)
	print("inputY", inputVector.y)
	if is_on_floor() and Input.is_action_just_pressed("s") and (can_state_change(SD.State.QUADSTOMP) or currentState == SD.State.QUADSTOMP):
	#if is_on_floor() and inputMovementAction and inputVector.y > 0 and (can_state_change(SD.State.QUADSTOMP) or currentState == SD.State.QUADSTOMP):
		if currentState == SD.State.QUADSTOMP:
			pass
		else:
			animationPlayer.play("Proto-QuadStomp")
			currentState = SD.State.QUADSTOMP
	if currentState & (SD.State.QUADSTOMP | SD.State.SQUAT):
		if(currentState & (SD.State.QUADSTOMP)):
			storedStompVelocity += (velocity - velocity.move_toward(Vector2.ZERO, STOMP_STOMP_SPEED * delta)).length()
		velocity = velocity.move_toward(Vector2.ZERO, STOMP_STOMP_SPEED * delta)
func _ready() -> void:
	animationPlayer.play("Proto-Idle")

func _physics_process(delta: float) -> void:
	
	process_input()
	# Add the gravity.
	if not is_on_floor(): 
		velocity -= AIR_DRAG*pow(velocity.length(),AIR_DRAG_DEGREE)*velocity.normalized() * delta
		velocity += get_gravity()*GRAVITYMODIFIER* delta
	else:
		velocity -= GROUND_DRAG*pow(velocity.length(),GROUND_DRAG_DEGREE)*velocity.normalized() * delta
	
	# Handle jump.
	handle_quad_stomp(delta)
	handle_jump(delta)
	handle_input_horizontal(delta)
	

	solve_state(delta)
	print(storedStompVelocity)
	move_and_slide()

func solve_state(delta : float)->void:
	if inputVector.x != 0:
		$Sprite2D.scale.x = -1 if inputVector.x > 0 else 1
	print(velocity)
	if(is_on_floor() and velocity.length() == 0 and can_state_change(SD.State.IDLE)):
		currentState = SD.State.IDLE
		animationPlayer.play("Proto-Idle")
	if(is_on_floor() and inputVector.x == 0 and velocity.length() != 0 and can_state_change(SD.State.SLIDING)):
		currentState = SD.State.SLIDING
		animationPlayer.play("Proto-Idle")
	if(is_on_floor() and velocity.x != 0 and inputVector.x != 0 and can_state_change(SD.State.RUNNING)):
		currentState = SD.State.RUNNING
		animationPlayer.play("Proto-Run")
		animationPlayer.seek(0.2)
	if(currentState == SD.State.SQUAT):
		storedCrouchVelocity += CROUCH_STORED_VELOCITY_GROWTH*delta
		storedCrouchVelocity = CROUCH_STORED_VELOCITY_MAX_BONUS if storedCrouchVelocity > CROUCH_STORED_VELOCITY_MAX_BONUS else storedCrouchVelocity
		if(Input.is_action_just_released("jump")):
			currentState = SD.State.RISING
			velocity.y += JUMP_VELOCITY
			velocity += Vector2.UP*storedStompVelocity
			velocity += Vector2.UP*storedCrouchVelocity
			storedCrouchVelocity = 0
			storedStompVelocity = 0
			animationPlayer.play("Proto-Rise")
	if  not is_on_floor() and can_state_change(SD.State.FALLING) and velocity.y > 0 and (((sqrt(abs(velocity.y))) > abs(velocity.x)) or not(currentState & SD.State.LEAPING)):
		animationPlayer.play("Proto-Fall")
		currentState = SD.State.FALLING


func can_state_change(transitionState : int)->bool:
	if (SD.stateTransitionTable[currentState] & transitionState) and \
	((SD.stateInteruptTable[currentState] & transitionState) or  (not animationPlayer.is_playing())):
		return true
	return false

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	#if(currentState == SD.State.QUADSTOMP):
	#	storedStompVelocity = 0;
	pass


func _on_animation_player_current_animation_changed(name: StringName) -> void:
	if( not (currentState & (SD.State.QUADSTOMP | SD.State.SQUAT))):
		storedStompVelocity = 0
		storedCrouchVelocity = 0
