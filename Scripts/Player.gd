extends CharacterBody3D

@export var move_speed: float = 7.5
@export var accel: float = 12.0
@export var air_control: float = 0.35
@export var jump_force: float = 5.6
@export var gravity: float = 17.0
@export var coyote_time: float = 0.12
@export var jump_buffer: float = 0.12

var _coyote_timer := 0.0
var _buffer_timer := 0.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	# Timers (coyote y buffer)
	if is_on_floor():
		_coyote_timer = coyote_time
	else:
		_coyote_timer = maxf(_coyote_timer - delta, 0.0)
	_buffer_timer = maxf(_buffer_timer - delta, 0.0)

	# Movimiento horizontal
	var input_dir := _get_move_input()
	var wish_vel := input_dir * move_speed
	var lerp_factor := accel if is_on_floor() else accel * air_control
	velocity.x = lerpf(velocity.x, wish_vel.x, lerp_factor * delta)
	velocity.z = lerpf(velocity.z, wish_vel.z, lerp_factor * delta)

	# Gravedad
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif velocity.y < 0.0:
		# amortigua caída para aterrizaje más "butter"
		velocity.y = -min(1.2, -velocity.y * 0.15)

	# Entrada de salto (buffer)
	if Input.is_action_just_pressed("jump"):
		_buffer_timer = jump_buffer

	# Ejecutar salto si hay buffer y coyote o estás en piso
	if _buffer_timer > 0.0 and (_coyote_timer > 0.0 or is_on_floor()):
		velocity.y = jump_force
		_buffer_timer = 0.0
		_coyote_timer = 0.0

	move_and_slide()

func _get_move_input() -> Vector3:
	# Dirección relativa a cámara (forward = -Z)
	var dir := Vector3.ZERO
	var forward := -global_transform.basis.z
	var right := global_transform.basis.x
	if Input.is_action_pressed("move_forward"): dir += forward
	if Input.is_action_pressed("move_back"):    dir -= forward
	if Input.is_action_pressed("move_right"):   dir += right
	if Input.is_action_pressed("move_left"):    dir -= right
	dir.y = 0.0
	return dir.normalized()
