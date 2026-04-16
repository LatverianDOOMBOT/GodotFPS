extends CharacterBody3D
class_name Enemy
@export var health : int
@export var speed : int
@export var collision_shape : CollisionShape3D
@export var mesh_instance : MeshInstance3D
@export var movement_speed: float = 4.0
@export var navigation_agent: NavigationAgent3D 
var previous_state = null
var player_detected : bool
func _process(delta: float) -> void:
	pass
		
		
func damage(damage : int) -> void:
	health -= damage
	print(health)
	

func _ready() -> void:
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func _physics_process(delta):
	if health <= 0:
		queue_free()
	if navigation_agent.is_navigation_finished():
		return

	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	#look_at(Vector3(position.x, next_path_position.y, position.z))
	var current_agent_position: Vector3 = global_position
	var new_velocity: Vector3 = (next_path_position - current_agent_position).normalized() * movement_speed
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	move_and_slide()	
