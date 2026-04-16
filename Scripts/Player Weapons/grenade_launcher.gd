extends Node3D
@export var current_weapon = false
@onready var grenade = preload("res://Scenes/Grenade.tscn")
@export var grenadeSpeed : int = 100
@onready var shootTimer = $shootTimer
var canShoot : bool = true
var bulletInstance
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("Shoot") && canShoot:
		print("shot fired")
		shoot()
				
		shootTimer.start()
		canShoot = false
				
				
	
				
func shoot():
	var grenadeInstance = grenade.instantiate()
	get_tree().root.add_child(grenadeInstance)  # add to root, not weapon's parent
	grenadeInstance.global_position = $grenadeSpawnPoint.global_position
	grenadeInstance.apply_central_impulse(-global_transform.basis.z * grenadeSpeed)
	


func _on_shoot_timer_timeout() -> void:
	canShoot = true
