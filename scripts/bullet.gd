extends Node3D
#class_name Bullet 

const SPEED = 40.0

@onready var bullet = $Sketchfab_Scene
@onready var ray = $RayCast3D
@onready var particles = $GPUParticles3D

func _ready():
	pass
	
func _process(delta):
	position += transform.basis * Vector3(0, 0, -SPEED) * delta
	# if bullet collides, create small explosion and destroy self
	if ray.is_colliding():
		bullet.visible = false
		particles.emitting = true
		ray.enabled = false
		if ray.get_collider().is_in_group("target"):
			print("hit ", ray.get_collider())
			ray.get_collider().hit()
		await get_tree().create_timer(1.0).timeout
		queue_free()


func _on_timer_timeout() -> void:
	queue_free()
	# bullet delete self when not hit for too long
