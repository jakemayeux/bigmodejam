extends State


func _ready() -> void:
	state_id  = Enemy_State_ID.DEATH

func enter(previous_state: State_ID = 0) -> void:
	animation_player.play("Death")

func physics_update(delta: float) -> void:
	if not animation_player.is_playing():
		pass
		
func can_enter_from(other_state : State_ID) -> bool:
	return false
