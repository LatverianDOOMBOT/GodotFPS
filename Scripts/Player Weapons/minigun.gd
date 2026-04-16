extends Node3D

@export var current_weapon = false
@onready var raycast = $RayCast3D
@onready var bullet = preload("res://Scenes/Bullet.tscn")
@export var bulletSpeed : int = 100
@onready var shootTimer = $ShootTimer
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
		if raycast.is_colliding():
			var object = raycast.get_collider()
			print(object)
			if object.is_in_group("enemies"):
				print("enemy struck")
				
		shootTimer.start()
		canShoot = false
				
				
	
				
func shoot():
	bulletInstance = bullet.instantiate()
	get_tree().root.add_child(bulletInstance)  # add to root, not weapon's parent
	bulletInstance.global_position = $BulletSpawnPoint.global_position
	bulletInstance.apply_central_impulse(-global_transform.basis.z * bulletSpeed)
	


func _on_shoot_timer_timeout() -> void:
	canShoot = true
