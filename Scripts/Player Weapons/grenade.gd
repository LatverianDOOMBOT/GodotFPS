extends RigidBody3D
var explosion : bool
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	continuous_cd = true
	$Timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	freeze = true
	explosion = true
	

	var bodies = $ExplosionArea.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			body.queue_free()
			
	$ExplosionWaitTime.start()
	





func _on_collide_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemies"):
		body.queue_free()
		queue_free()


func _on_explosion_area_body_entered(body: Node3D) -> void:
	if explosion:
		if body.is_in_group("enemies"):
			print(body)
			body.queue_free()


			
			
		


func _on_explosion_wait_time_timeout() -> void:
	queue_free()
