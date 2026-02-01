extends State

@export var velocity_charge_curve : Curve
var velocity_charge_total : float = PlayerConstants.CHARGE_WIND_UP_VELOCITY_0
var velocity_charge_timer : float = 0
var velocity_charge_state : int = 0

func _ready() -> void:
	state_id = State_ID.CHARGEWINDHOLD

func exit() -> void:
	physics_body.vfx_player.play("None")
	pass

func enter(previous_state: State_ID = 0) -> void:
	animation_player.play("Proto-ChargeHold")
	velocity_charge_total = PlayerConstants.CHARGE_WIND_UP_VELOCITY_0
	velocity_charge_timer = 0
	velocity_charge_state = 0

func physics_update(delta: float) -> void:
	#physics_body.stored_stomp_velocity += (physics_body.velocity - physics_body.velocity.move_toward(Vector2.ZERO, PlayerConstants.STOMP_STOMP_SPEED * delta)).length()
	
	physics_body.velocity = physics_body.velocity.move_toward(Vector2.ZERO, PlayerConstants.STOMP_STOMP_SPEED * delta)
	if (velocity_charge_timer <= velocity_charge_curve.max_domain):
		velocity_charge_total = velocity_charge_curve.sample(velocity_charge_timer) + PlayerConstants.CHARGE_WIND_UP_VELOCITY_0
	
	physics_body.vfx_parent.scale.x = physics_body.get_node("Sprite2D").scale.x
	
	choose_shine_vfx(delta)
	
	print("stored vel:", velocity_charge_total)
	if(Input.is_action_just_released("MovmentAction")):
		physics_body.velocity.x = velocity_charge_total*physics_body.get_node("Sprite2D").scale.x*-1
		if(velocity_charge_total > 600):
			change_state(State_ID.CHARGEFORWARD)
		else:
			change_state(State_ID.SLIDING)

func can_enter_from(other_state : State_ID) -> bool:
	return false

func choose_shine_vfx(delta : float)->void:
	if(velocity_charge_timer >= PlayerConstants.CHARGE_WIND_HOLD_TIME_3 +  PlayerConstants.CHARGE_WIND_HOLD_TIME_2 + PlayerConstants.CHARGE_WIND_HOLD_TIME_1):
		physics_body.vfx_player.play("SmallShine-3")
	elif(velocity_charge_timer >= PlayerConstants.CHARGE_WIND_HOLD_TIME_2 + PlayerConstants.CHARGE_WIND_HOLD_TIME_1):
		physics_body.vfx_player.play("SmallShine-2")
	elif(velocity_charge_timer >= PlayerConstants.CHARGE_WIND_HOLD_TIME_1):
		physics_body.vfx_player.play("SmallShine-1")
	velocity_charge_timer += delta
	
