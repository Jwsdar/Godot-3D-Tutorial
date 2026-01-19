extends CharacterBody3D

# Basic Movement Variables
var speed
const WALK_SPEED = 2.0
const SPRINT_SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003

# Bob Varibles
const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob = 0.0

# FOV Variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

# References to nodes must be saved in onready variables
@onready var head = $Head
@onready var camera = $Head/Camera3D



func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		#Clamp Function limits variable (rotation of camera) between a minimum and maximum parameter (angle)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
		
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Handle Sprint
	if Input.is_action_pressed("Sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("Left", "Right", "Up", "Down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#Adding Inertia:
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta*7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta*7.0)
	else:
		#lerp() changes varible (speed) incrementally
		velocity.x = lerp(velocity.x, direction.x * speed, delta*4.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta*4.0)
		
	# Head Bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.1, SPRINT_SPEED*10) #FOV doesnt go craxy whilst falling
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta*8.0)
	
	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time*BOB_FREQ) * BOB_AMP
	pos.x = cos(time*BOB_FREQ/2)  * BOB_AMP
	return pos
