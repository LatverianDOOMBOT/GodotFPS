extends Enemy

enum State { IDLE, LOOK, ATTACK, CHARGE, STUN }
@onready var detected_area = $DetectedArea
@onready var stun_check = $StunCheck
@onready var stun_timer = $Stun
var stun_timer_started = false


var state = State.IDLE

func _ready():
	pass
	
func _process(delta):
	
	print("state: ", State.keys()[state])
	state_setter(delta)
	
func state_setter(delta: float):
	match state:
		State.IDLE:
			pass
			
		State.LOOK:
			LOOK(delta)
			
		State.ATTACK:
			CHARGE()
			
		State.STUN:
			STUN()
			

func LOOK(delta: float) -> void:
	stun_timer_started = false
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
	
func CHARGE() -> void:
	velocity = global_transform.basis.z * speed 
	move_and_slide()
	
func STUN():
	if !stun_timer_started:
		stun_timer.start(3)
		stun_timer_started = true


func _on_detected_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") && state == State.IDLE:
		state = State.LOOK


func _on_sight_check_body_entered(body: Node3D) -> void:
	if state == State.LOOK && body.is_in_group("player"):
		state = State.ATTACK
		


func _on_stun_check_body_entered(body: Node3D) -> void:
	print(body)
	if state == State.ATTACK and body is StaticBody3D and !body.is_in_group("floor"):
		state = State.STUN
		
		
	if state == State.ATTACK and body.is_in_group("player") and is_instance_valid(body):
		body.OnPlayerDamaged(10)
		body.bounce_back(self.global_position) 
		state = State.LOOK


func _on_stun_timeout() -> void:
	if state == State.STUN:
		state = State.LOOK
