extends State


func _ready() -> void:
	state_id  = Enemy_State_ID.IDLE

func enter(previous_state: State_ID = 0) -> void:
	animation_player.play("Idle")

func physics_update(delta: float) -> void:
	pass
		
func can_enter_from(other_state : State_ID) -> bool:
	return false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Player")):
		change_state(Enemy_State_ID.DEATH)
