extends CharacterBody3D

@onready var camera_mount = $camera_mount
@onready var animation_player: AnimationPlayer = $model/skeleton_mage/AnimationPlayer

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var movement_sens = 0.5

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * movement_sens))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * movement_sens))
		camera_mount.rotation.x = clamp(camera_mount.rotation.x, deg_to_rad(-90), deg_to_rad(30))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

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
