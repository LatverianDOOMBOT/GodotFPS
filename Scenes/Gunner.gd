extends Enemy

enum State {IDLE, LOOK, ATTACK, STUN}
@onready var detection = $detectionarea
var canShoot : bool = true
@onready var agent: NavigationAgent3D = $NavigationAgent3D
var player 
var state
var is_in_line_of_sight : bool = false

@export var keep_distance: float = 8.0
@export var retreat_distance: float = 10.0
func state_setter(delta: float):
	match state:
		State.IDLE:
			pass
			
		State.LOOK:
			LOOK(delta)
			
		State.ATTACK:
			ATTACK()
			
		State.STUN:
			STUN()
			
func ATTACK():
	if not has_line_of_sight():
		state = State.LOOK
		return

	if canShoot:
		player.OnPlayerDamaged(10)
		$ShootTimer.start()
		canShoot = false
func STUN():
	pass
func LOOK(delta: float):
	var target: Node3D = get_tree().get_first_node_in_group("player") as Node3D
	if target == null:
		return

	var flat_target_pos: Vector3 = target.global_position
	flat_target_pos.y = global_position.y

	var rotate_speed: float = 5.0
	var current_basis: Basis = global_transform.basis.orthonormalized()
	var desired_basis: Basis = global_transform.looking_at(flat_target_pos, Vector3.UP, true).basis.orthonormalized()
	var t: float = clamp(rotate_speed * delta, 0.0, 1.0)

	global_transform.basis = current_basis.slerp(desired_basis, t)
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

var last_flee_target: Vector3 = Vector3.INF
func has_line_of_sight() -> bool:
	$shootRay.force_raycast_update()
	if not $shootRay.is_colliding():
		return false

	var hit = $shootRay.get_collider()
	return hit and hit.is_in_group("player")

func _physics_process(delta: float) -> void:
	if health <= 0:
		queue_free()
	if player == null:
		return

	var to_player: Vector3 = player.global_position - global_position
	to_player.y = 0.0
	var dist: float = to_player.length()

	if dist < keep_distance:
		var away_dir: Vector3 = (-to_player).normalized()
		var flee_target: Vector3 = global_position + away_dir * retreat_distance

		if last_flee_target == Vector3.INF or last_flee_target.distance_to(flee_target) > 0.5:
			agent.target_position = flee_target
			last_flee_target = flee_target
	else:
		last_flee_target = Vector3.INF

	var next_pos: Vector3 = agent.get_next_path_position()
	var move_dir: Vector3 = next_pos - global_position
	move_dir.y = 0.0

	if move_dir.length() > 0.05:
		move_dir = move_dir.normalized()
		velocity.x = move_dir.x * speed
		velocity.z = move_dir.z * speed
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()
	if has_line_of_sight():
		state = State.ATTACK
	else:
		state = State.LOOK
	
	
func _process(delta: float) -> void:
	state_setter(delta)

func _on_detectionarea_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		state = State.LOOK





func _on_shoot_timer_timeout() -> void:
	canShoot = true
