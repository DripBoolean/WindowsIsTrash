extends CharacterBody3D

var camera_rotation = Vector2(0, 0)
const JUMP_VELOCITY = 1
const SPEED = 5.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
const SENSITIVITY = 0.005

const PROJECTILE_SPEED = 20.0

# Head bob effect
const BOB_FREQ = 2.4
const BOB_AMP = 0.2
var t_bob = 0.0

var projectile_scene = preload("res://scenes/player_and_parts/projectile.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#velocity = Vector3(10, 0, 0).rotated(Vector3(0, 1, 0), camera_rotation.x + PI / 2)
	#move_and_slide()
	
@onready var head = $Head
@onready var camera = $Head/Camera
	
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
	
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("menu"):
		get_tree().quit()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("strafe_left", "strafe_right", "move_forward", "move_backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if(Input.is_action_just_pressed("shoot")):
		shoot()
		
	#Head bob
	#t_bob *= delta * velocity.length() * float(is_on_floor())
	#camera.transform.origin = _headbob(t_bob)

	move_and_slide()
		
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ/2)
	return pos
	
func shoot():
	var new_projectile = projectile_scene.instantiate()
	new_projectile.velocity = -camera.get_global_transform().basis.z * PROJECTILE_SPEED
	print(camera.get_global_transform().basis.z)
	new_projectile.position = camera.global_position
	print(camera.global_position)
	$"../".add_child(new_projectile)
	

#func _input(event):
	#if event is InputEventMouseMotion:
		#camera_rotation += event.relative * -0.05
		#camera_rotation.y = clamp(camera_rotation.y, -PI / 2, PI / 2)
		#$Camera.transform.basis = Basis() # reset rotation
		#$Camera.rotate_object_local(Vector3(0, 1, 0), camera_rotation.x)
		#$Camera.rotate_object_local(Vector3(1, 0, 0), camera_rotation.y)
	
		
