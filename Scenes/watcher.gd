extends Enemy

enum State { IDLE, MOVE, ATTACK, DELAY }

var state = State.IDLE

@onready var attacktimer = $AttackTimer
@onready var attackdelaytimer = $AttackDelayTimer

@onready var area = $detectedArea
@onready var shape = area.get_node("CollisionShape3D").shape

var player


var spikeScene = preload("res://Scenes/spike.tscn")
var spikes = []

func _ready() -> void:
	attackdelaytimer.wait_time = 2

# --------------------------------------------------
# RANDOM POSITION (handles scale + rotation)
# --------------------------------------------------

func get_random_teleport_point_away_from_player(min_dist: float, max_dist: float, tries: int = 20) -> Vector3:
	if not player:
		return global_position

	var nav_map: RID = $NavigationAgent3D.get_navigation_map()

	for i in tries:
		var angle = randf_range(0.0, TAU)
		var dist = randf_range(min_dist, max_dist)

		var offset = Vector3(cos(angle) * dist, 0.0, sin(angle) * dist)
		var desired_point = player.global_position + offset

		var nav_point = NavigationServer3D.map_get_closest_point(nav_map, desired_point)

		if nav_point.distance_to(player.global_position) >= min_dist and nav_point.distance_to(player.global_position) <= max_dist:
			return nav_point

	return global_position
	
func teleport_away_from_player():
	var pos = get_random_teleport_point_away_from_player(8.0, 15.0)
	global_position = pos
	return true

# --------------------------------------------------
# MAIN LOOP
# --------------------------------------------------

func _physics_process(delta):
	if health <= 0:
		queue_free()
	print("HEALTH: ", health)
	match state:

		State.IDLE:
			if player_detected:
				state = State.MOVE

		State.MOVE:
			if teleport_away_from_player():
				if player:
					look_at(player.global_position, Vector3.UP)

				attacktimer.start()
				state = State.ATTACK
			else:
				print("Failed to find teleport position")

		State.ATTACK:
			# waiting for timer signal
			pass

		State.DELAY:
			# waiting for delay timer
			pass

# --------------------------------------------------
# ATTACK LOGIC
# --------------------------------------------------

func do_attack():
	print("SPAWNING")

	var spikeInstance = spikeScene.instantiate()
	get_tree().root.add_child(spikeInstance)

	if player and player.collision_point_ground:
		spikeInstance.global_position = player.collision_point_ground
		spikes.append(spikeInstance)
	else:
		# fallback so it NEVER breaks
		spikeInstance.global_position = global_position

# --------------------------------------------------
# SIGNALS
# --------------------------------------------------

func _on_attack_timer_timeout():
	if state != State.ATTACK:
		return

	do_attack()
	attackdelaytimer.start()
	state = State.DELAY


func _on_attack_delay_timer_timeout():
	if state != State.DELAY:
		return

	state = State.MOVE


func _on_detected_area_body_entered(body: Node3D):
	if body.is_in_group("player"):
		player_detected = true
		player = body
		state = State.MOVE
		
		
