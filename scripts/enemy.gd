extends Node3D

@export var health = 5

@onready var particle: GPUParticles3D = $GPUParticles3D
@onready var target: MeshInstance3D = $model

func got_hit() -> void:
	health -= 1
	if health <= 0:
		# play death explosion and destroy self
		target.visible = false
		particle.emitting = true
		await get_tree().create_timer(1.0).timeout
		queue_free()
