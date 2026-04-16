extends RigidBody3D

@export var damage : int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.start()
	continuous_cd = true



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass





func _on_timer_timeout() -> void:
	queue_free()


func _on_bullet_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemies"):
		print("yessir")
		body.damage(damage)
		queue_free()
