extends CharacterBody3D

@onready var camera_mount = $camera_mount
@onready var animation_player: AnimationPlayer = $model/skeleton_mage/AnimationPlayer
@onready var bullet_spawner = $camera_mount/Camera3D/RayCast3D
@onready var camera = $camera_mount/Camera3D
# movements 
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@export var movement_sens = 0.5
# bullets
var bullet = load("res://scenes/bullet.tscn")
var instance
var shoot = false
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * movement_sens))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * movement_sens))
		camera_mount.rotation.x = clamp(camera_mount.rotation.x, deg_to_rad(-30), deg_to_rad(30))
	pass


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# exit game
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
		
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if animation_player.current_animation != "Running_B":
			animation_player.play("Running_B")
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		if animation_player.current_animation != "Idle_B":
			animation_player.play("Idle_B")
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	# shooting
	if Input.is_action_pressed("shoot"):
		if shoot == false:
			shoot = true
			instance = bullet.instantiate()
			instance.position = bullet_spawner.global_position

			# Cast a ray from camera center (crosshair) to find target point
			var space_state = get_world_3d().direct_space_state
			var camera_pos = camera.global_position
			var camera_forward = -camera.global_transform.basis.z

			var query = PhysicsRayQueryParameters3D.create(camera_pos, camera_pos + camera_forward * 1000)
			var result = space_state.intersect_ray(query)

			var target_point
			if result:
				target_point = result.position
			else:
				# If no collision, aim far forward from camera
				target_point = camera_pos + camera_forward * 100

			var bullet_direction = (target_point - instance.position).normalized()
			instance.transform.basis = Basis.looking_at(bullet_direction)

			get_parent().add_child(instance)
			# waiting for "reload time"
			await get_tree().create_timer(0.3).timeout
			shoot = false
