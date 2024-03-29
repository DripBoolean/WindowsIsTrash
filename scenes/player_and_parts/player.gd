extends CharacterBody3D

var camera_rotation = Vector2(0, 0)
const JUMP_VELOCITY = 5
const SPEED = 1.5
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
const SENSITIVITY = 0.005

const PROJECTILE_SPEED = 20.0

# Head bob effect
const BOB_FREQ = 2.4
const BOB_VERTICAL_AMP = 2.0
const BOB_HORIZONTAL_AMP = 1.0
var t_bob = 0.0

var projectile_scene = preload("res://scenes/player_and_parts/projectile.tscn")
var popup_scene = preload("res://scenes/player_and_parts/popup.tscn")

var rng = RandomNumberGenerator.new()

@onready var head = $Head
@onready var camera = $Head/Camera
@onready var guncam = $Head/hand/gun/SubViewportContainer/SubViewport/GunCam
@onready var activation_cast = $Head/Camera/ActivationCast

# GUN SWAY
@onready var hand_loc = $Head/hand_location
@onready var hand = $Head/hand
const SWAY = 30
const VSWAY = 40

# HEALTH
@export var health: float = 100.0
@onready var healthbar = $player_HUD/healthbar
	
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	healthbar.init_health(health)
	#hand.set_as_top_level(true)
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			head.rotate_y(-event.relative.x * SENSITIVITY)
			camera.rotate_x(-event.relative.y * SENSITIVITY)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
		
func _process(_delta):
	guncam.global_transform = camera.global_transform
	#hand.global_transform.origin = hand_loc.global_transform.origin
	#hand.rotation.y = lerp_angle(hand.rotation.y, rotation.y, SWAY * delta)
	#hand.rotation.x = lerp_angle(hand.rotation.x, head.rotation.x, VSWAY * delta)
	if health <= 0:
		get_tree().paused = true
		await get_tree().create_timer(1).timeout
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/player_and_parts/deathscene.tscn")
		return
		
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
	var direction = (head.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction.y = 0
	if Input.is_action_pressed("sprint"):
		direction *= 1.4
	
	velocity *= 0.8
	
	if direction:
		velocity += direction * SPEED
	
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if(Input.is_action_just_pressed("shoot")):
			if not Input.is_action_pressed("sprint"):
				shoot()		
	#Head bob
	t_bob += delta * velocity.length()
	if(not is_on_floor()):
		t_bob = 0
	head.position = Vector3.ZERO
	head.translate_object_local(headbob(t_bob) * velocity.length() * 0.01)
	#camera.transform.origin = _headbob(t_bob)
	
	if(Input.is_action_just_pressed("activate")):
		if(activation_cast.is_colliding()):
			print("Hit  Something")
			var collider = activation_cast.get_collider()
			if(collider.is_in_group("activatable")):
				collider.activate()
				print("Activated Something")
	
	if(Input.is_action_just_pressed("tab_out")):
		if(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	rotate_step_up_ray()
	move_and_slide()
	_walk_down_stairs_check()
		
func headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_VERTICAL_AMP
	pos.x = sin(time * BOB_FREQ/2) * BOB_HORIZONTAL_AMP
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
	health -= 10
	healthbar.health = health
	
func infect_adware():
	var num_popups = rng.randi_range(2, 3)
	$popup.play()
	for i in num_popups:
		var popup = popup_scene.instantiate()
		add_child(popup)
	
	health -= 1
	

#func _input(event):
	#if event is InputEventMouseMotion:
		#camera_rotation += event.relative * -0.05
		#camera_rotation.y = clamp(camera_rotation.y, -PI / 2, PI / 2)
		#$Camera.transform.basis = Basis() # reset rotation
		#$Camera.rotate_object_local(Vector3(0, 1, 0), camera_rotation.x)
		#$Camera.rotate_object_local(Vector3(1, 0, 0), camera_rotation.y)
	
		
