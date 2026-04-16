extends CharacterBody3D

var speed = 5.0
var jump_speed = 4.5
var jump_counter = 0
@onready var camera = $Head/Camera3D
const STAND_HEIGHT = 1.8
const CROUCH_HEIGHT = 0.9
@onready var groundRayCast = $groundRaycast

var mouse_sensitivity : float = 0.3
@onready var playerColShape = $PlayerCollisionShape
@onready var playerMesh = $PlayerMeshInstance
@onready var crouchCast = $Crouch
@onready var shootRay = $Head/Camera3D/shootRay
var gravity = 15
var weapons = []
var is_dashing = false
var is_crouching : bool = false
var initial_camera_ypos : float
var collision_point_ground
var dash_duration = 0.2
var dash_timer = 0.0
var dash_force = 30.0
var dash_direction = Vector3.ZERO
var current_weapon
@onready var head = $Head
@onready var playerHealthBar = $Head/Camera3D/CanvasLayer/PlayerUI/HealthBar
func _ready() -> void:
	weapons = [$Head/Camera3D/WeaponHolder/Shotgun, $Head/Camera3D/WeaponHolder/Minigun, $Head/Camera3D/WeaponHolder/GrenadeLauncher]
	add_to_group("player")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	WeaponChange(0)
	print(current_weapon)
	shootRay.position = Vector3.ZERO
	shootRay.target_position = Vector3(0, 0, -50)
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		camera.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
func _physics_process(delta: float) -> void:
	velocity.y += -gravity * delta
	print(camera.position.y)
	var input = Input.get_vector("Left", "Right", "Forward", "Backward")
	var movement_dir = transform.basis * Vector3(input.x, 0, input.y)

	# Dash input
	if Input.is_action_just_pressed("Dash") and not is_dashing:
		is_dashing = true
		dash_timer = dash_duration
		# Dash in movement direction, or forward if standing still
		dash_direction = movement_dir if movement_dir.length() > 0.1 else -global_transform.basis.z
		dash_direction = dash_direction.normalized()
	if Input.is_action_just_pressed("Shotgun"):
		WeaponChange(0)
		
	if Input.is_action_just_pressed("Minigun"):
		WeaponChange(1)
		
	if Input.is_action_just_pressed("GrenadeLauncher"):
		WeaponChange(2)
		
	if Input.is_action_pressed("Crouch"):
		is_crouching = true
		crouch(is_crouching)
		
	elif Input.is_action_just_released("Crouch"):
		is_crouching = false
		if !crouchCast.is_colliding():
			crouch(is_crouching)
		
	if !is_crouching && !crouchCast.is_colliding():
		crouch(false)
		
		
	# Apply dash
	if is_dashing:
		dash_timer -= delta
		velocity.x = dash_direction.x * dash_force
		velocity.z = dash_direction.z * dash_force
		
		if dash_timer <= 0.0:
			OnPlayerDamaged(2)
			is_dashing = false
	else:
		velocity.x = movement_dir.x * speed
		velocity.z = movement_dir.z * speed

	move_and_slide()

	if is_on_floor() and Input.is_action_just_pressed("Jump"):
		jump_counter += 1
		velocity.y = jump_speed

	if jump_counter >= 2 && is_on_floor():
		jump_counter = 0

	if !is_on_floor() and Input.is_action_just_pressed("Jump") && jump_counter < 2:
		jump_counter += 1
		velocity.y = jump_speed + 10
		OnPlayerDamaged(8)

	if Input.is_action_pressed("Sprint"):
		speed = 10.0
	else:
		speed = 5.0
		
	if groundRayCast.is_colliding():
		print("colliding")
		collision_point_ground = groundRayCast.get_collision_point()
		print("HIT:", collision_point_ground)


func crouch(enable: bool):
	var shape = playerColShape.shape
	shape.height = CROUCH_HEIGHT if enable else STAND_HEIGHT
	# Remove the position.y line entirely
	head.position.y = 0.5688  # slight offset so cam stays inside shape
func OnPlayerDamaged(damage : int):
	playerHealthBar.value -= damage
	GameManager.playerHealth -= damage
	
func WeaponChange(index):
	# Disable ALL weapons first
	for weapon in weapons:
		weapon.visible = false
		weapon.set_process(false)

	current_weapon = weapons[index]
	current_weapon.visible = true
	current_weapon.set_process(true)
	
