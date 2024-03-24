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

	
@onready var head = $Head
@onready var camera = $Head/Camera
@onready var guncam = $Head/hand/gun/SubViewportContainer/SubViewport/GunCam

# GUN SWAY
@onready var hand_loc = $Head/hand_location
@onready var hand = $Head/hand
const SWAY = 30
const VSWAY = 40
	
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#hand.set_as_top_level(true)
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
		
func _process(delta):
	guncam.global_transform = camera.global_transform
	#hand.global_transform.origin = hand_loc.global_transform.origin
	#hand.rotation.y = lerp_angle(hand.rotation.y, rotation.y, SWAY * delta)
	#hand.rotation.x = lerp_angle(hand.rotation.x, head.rotation.x, VSWAY * delta)
		
@onready var init_seperation_ray_dist = abs($step_up_ray.position.z)
func rotate_step_up_ray():
	var xz_vel = velocity * Vector3(1, 0, 1)
	var xz_ray_pos = xz_vel.normalized() * init_seperation_ray_dist
	$step_up_ray.global_position.x = self.global_position.x + xz_ray_pos.x
	$step_up_ray.global_position.z = self.global_position.z + xz_ray_pos.z
	
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
	
	rotate_step_up_ray()
	move_and_slide()
	_walk_down_stairs_check()
		
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ/2)
	return pos

var was_on_floor_last_frame = false	
var snapped_to_staris_last_frame = false
func _walk_down_stairs_check():
	var did_snap = false
	if not is_on_floor() and velocity.y <= 0 and (was_on_floor_last_frame or snapped_to_staris_last_frame) and $stair_check.is_colliding():
		var body_test_result = PhysicsTestMotionResult3D.new()
		var params = PhysicsTestMotionParameters3D.new()
		var max_step_down = -0.5
		params.from = self.global_transform
		params.motion = Vector3(0, max_step_down, 0)
		if PhysicsServer3D.body_test_motion(self.get_rid(), params, body_test_result):
			var translate_y = body_test_result.get_travel().y
			self.position.y += translate_y
			apply_floor_snap()
			did_snap = true
		
	was_on_floor_last_frame = is_on_floor()
	snapped_to_staris_last_frame = did_snap
	
func shoot():
	var new_projectile = projectile_scene.instantiate()
	new_projectile.linear_velocity = -camera.get_global_transform().basis.z * PROJECTILE_SPEED
	new_projectile.position = $Head/hand/gun/gun_hole.global_position
	$"../".add_child(new_projectile)
	
func take_damage():
	print("MEWOUCH")
	

#func _input(event):
	#if event is InputEventMouseMotion:
		#camera_rotation += event.relative * -0.05
		#camera_rotation.y = clamp(camera_rotation.y, -PI / 2, PI / 2)
		#$Camera.transform.basis = Basis() # reset rotation
		#$Camera.rotate_object_local(Vector3(0, 1, 0), camera_rotation.x)
		#$Camera.rotate_object_local(Vector3(1, 0, 0), camera_rotation.y)
	
		
