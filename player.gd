extends CharacterBody3D

# How fast the player moves in meters per second.
@export var speed = 14
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75
# Vertical impulse applied to the character upon jumping in meters per second.
@export var jump_impulse = 20
@export_range(0.0, 1.0) var mouse_sensitivity = 0.5

@onready var _camera_pivot := $CameraPivot as Node3D

var target_velocity = Vector3.ZERO

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		_camera_pivot.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))

func _physics_process(delta):
	# Vertical Velocity
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
		
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		target_velocity.y = jump_impulse
		
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		target_velocity.x = direction.x * speed
		target_velocity.z = direction.z * speed
	else:
		target_velocity.x = move_toward(target_velocity.x, 0, speed)
		target_velocity.z = move_toward(target_velocity.z, 0, speed)

	# Moving the Character
	velocity = target_velocity
	move_and_slide()
	
	# Check for collisions after movement.
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider.name == "Ball":
			# You can apply force to the ball here.
			var push_force = 0.5
			var push_vector = collision.get_normal() * -push_force
			collider.apply_central_impulse(push_vector)
