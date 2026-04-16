extends Node3D
@export var current_weapon = false
@export var raycast : RayCast3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Shoot"):
		print("shot fired")
		if raycast.is_colliding():
			var object = raycast.get_collider()
			print(object)
			if object.is_in_group("enemies"):
				print("enemy struck")
				

	
