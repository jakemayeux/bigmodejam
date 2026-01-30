class_name Player extends CharacterBody2D

@onready var animation : AnimatedSprite2D = $AnimatedSprite2D

var accel : float = 300.0
var top_speed : float = 10.0
var stop_speed : float = 1500.0
var jump_power : float = 500.0
var climb_speed : float = 200.0

var stored_potential : float = 0.0

var sliding_on_wall : bool = false
var facing_dir : float = -1
#var velocity : Vector2 = Vector2.ZERO

func _input(event: InputEvent) -> void:
	var key_event = event as InputEventKey
	if key_event and key_event.keycode == KEY_ESCAPE and OS.has_feature("editor"):
		get_tree().quit()

func _physics_process(delta: float) -> void:
	var run_dir : float = Input.get_axis(&"a", &"d")
	var up_down : float = Input.get_axis(&"w", &"s")

	if run_dir > 0:
		animation.flip_h = true
		facing_dir = run_dir
	elif run_dir < 0:
		animation.flip_h = false
		facing_dir = run_dir

	if abs(run_dir) > 0:
		animation.play(&"run")
	else:
		animation.play(&"idle")

	if Input.is_action_just_pressed(&"s") and is_on_floor():
		stored_potential = velocity.length()

	if Input.is_action_pressed(&"s") and is_on_floor():
		velocity = velocity.move_toward(Vector2.ZERO, stop_speed * delta)
		animation.play(&"squat")
	else:
		stored_potential = 0

	if Input.is_action_just_pressed(&"jump") and is_on_floor():
		velocity.y -= jump_power + stored_potential

	velocity.x += run_dir * accel * delta

	var gravity : Vector2 = get_gravity()
	sliding_on_wall = is_on_wall() and -facing_dir == get_wall_normal().x and velocity.y >= 0
	if sliding_on_wall:
		gravity /= 2.0

		if Input.is_action_pressed(&"grab"):
			gravity.y = 0
			velocity.y = up_down * climb_speed

	velocity.y += gravity.y * delta * 2.0

	move_and_slide()
