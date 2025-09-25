extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var cam_holder : Node3D = $camHolder
@export var mouse_sens : float = 0.09

#speed variables
@export var current_speed : float = 5.0
@export var walking_speed : float = 5.0
@export var sprinting_speed : float = 8.0

#states
var walking = false
var sprinting = false

#cam tilt vars
@onready var cam_tilt : Node3D = $camHolder/CamTilt
@export var cam_rotation_amount : float = 0.07

#head bobbings vars
@onready var view_bobbing : Node3D = $camHolder/CamTilt/ViewBobbing
const head_bobbing_sprinting_speed : float = 16.0
const head_bobbing_walking_speed : float = 14.0
const head_bobbing_sprinting_intensity : float = 0.17
const head_bobbing_walking_intensity : float = 0.1
var head_bobbing_current_intencity = 0.0
var head_bobbing_vector = Vector2.ZERO
var head_bobbing_index = 0.0

#movement vars
@export var jump_velocity : float = 4.5
var def_head_pos_y : float
var lerp_speed : float = 10.0
var air_lerp_speed : float = 3.0

var last_velocity = Vector2.ZERO
var direction : Vector3

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	#mouse looking
	if event is InputEventMouseMotion:
		cam_holder.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		cam_holder.rotation.x = clamp(cam_holder.rotation.x, deg_to_rad(-89),deg_to_rad(89))
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))

func _physics_process(delta):
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	
	if Input.is_action_pressed("sprint"):
		#sprinting
		current_speed = lerp(current_speed, sprinting_speed, delta * lerp_speed)
		walking = false
		sprinting = true
	else:
		#walking
		current_speed = lerp(current_speed, walking_speed, delta * lerp_speed)
		walking = true
		sprinting = false

	#handle headbob
	if sprinting:
		head_bobbing_current_intencity = head_bobbing_sprinting_intensity
		head_bobbing_index += head_bobbing_sprinting_speed * delta
	elif walking:
		head_bobbing_current_intencity = head_bobbing_walking_intensity
		head_bobbing_index += head_bobbing_walking_speed * delta

	if is_on_floor() and input_dir != Vector2.ZERO:
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index/2) + 0.5
		
		view_bobbing.position.y = lerp(view_bobbing.position.y, head_bobbing_vector.y * (head_bobbing_current_intencity/2.0), delta * lerp_speed)
		view_bobbing.position.x = lerp(view_bobbing.position.x, head_bobbing_vector.x * head_bobbing_current_intencity, delta * lerp_speed)
	else:
		view_bobbing.position.y = lerp(view_bobbing.position.y, 0.0, delta * lerp_speed)		
		view_bobbing.position.x = lerp(view_bobbing.position.x, 0.0, delta * lerp_speed)
		
		

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if is_on_floor():
		direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_speed)
	else:
		if input_dir != Vector2.ZERO:
			direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * air_lerp_speed)
		
		
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	move_and_slide()
	cam_tilt_func(input_dir.x, cam_rotation_amount, delta)

func cam_tilt_func(input_x, rot, delta):
	if cam_tilt:
		cam_tilt.rotation.z = lerp(cam_tilt.rotation.z, -input_x * rot, 10 * delta)


func _on_melee_manager_applied_impulse(dir):
	print(dir)
	if is_on_floor():
		direction = transform.basis * Vector3.FORWARD * dir
	else:
		direction = transform.basis * Vector3.FORWARD * dir * 0.5
	pass # Replace with function body.
	
	#abcd
