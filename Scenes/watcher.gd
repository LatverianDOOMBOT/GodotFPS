extends Enemy
@onready var attackdelaytimer = $AttackDelayTimer
@onready var attackdurationtimer = $AttackDurationTimer
@onready var attacktimer = $AttackTimer
var player 
var spikeScene = preload("res://Scenes/spike.tscn")
var timers_set = false
var rng = RandomNumberGenerator.new()
var attacked = false
func _ready() -> void:
	
	rng.randomize()
func _process(delta):
	if player_detected:
		set_movement_target(player.position)
		look_at(player.global_position, Vector3.UP)
		if !timers_set:
			print("resetting timers")
			attackdelaytimer.wait_time = rng.randf_range(0.5, 1)
			attackdurationtimer.wait_time = rng.randf_range(0.5, 1)
			attacktimer.wait_time = rng.randf_range(0.5, 1)
			attacktimer.start()
			timers_set = true
func _on_detection_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_detected = true
		player = body


func _on_detected_area_body_entered(body: Node3D) -> void:
	pass
	#if body.is_in_group("player") && player_detected:
		#set_movement_target(body.position)


func _on_attack_timer_timeout() -> void:
	attacked = false
	Attack()
	
	
func Attack():
	if !attacked:
		
		print("SPAWNING")
		var spikeInstance = spikeScene.instantiate()
		get_tree().root.add_child(spikeInstance)
		if player and player.collision_point_ground:
			spikeInstance.global_position = player.collision_point_ground
			print(player.collision_point_ground)
			attacked = true
			timers_set = false
		else:
			print("Player or collision_point_ground is null")
