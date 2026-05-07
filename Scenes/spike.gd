extends Node3D

func _ready() -> void:
	$Timer.start()

func _on_spike_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.OnPlayerDamaged(10)


func _on_timer_timeout() -> void:
	queue_free()
