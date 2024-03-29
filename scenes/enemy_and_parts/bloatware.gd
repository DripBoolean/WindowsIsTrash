extends CharacterBody3D

@onready var eyes = $Eyes
@onready var los = $Eyes/LineOfSightRaycast
@onready var bracer_arm = $BracerArm
@onready var movement_raycast = $BracerArm/MovementRaycast

@onready var bloat_body = $model.get_active_material(0)
@onready var bloat_cloud = $cloud.get_active_material(0)

var active = false
var clockwise = true
var swapping_direction = false
var strafing_velocity = 0
var target_strafing_velocity = 0
var max_strafing_velocity = 5
var aproach_speed = 3.0
var attention = 10
var health = 10
var bracing_timer = 0.0

func sees_player():
	if los.is_colliding():
		var collider = los.get_collider()
		if collider != null:
			if collider.is_in_group("player"):
				return true
	return false
				
func _physics_process(delta):
	var player = get_tree().get_first_node_in_group("player")
	eyes.look_at(player.global_transform.origin, Vector3.UP)
	
	if bloat_body.get_shader_parameter("red") >= 0.0:
		bloat_body.set_shader_parameter("red", bloat_body.get_shader_parameter("red") - delta * 1.2)
		bloat_cloud.set_shader_parameter("red", bloat_cloud.get_shader_parameter("red") - delta * 1.2)
	
	if health <= 0:
		queue_free()
		return
	
	if sees_player():
		attention = 10
		active = true
	else:
		if active:
			attention -= delta
	
	if attention < 0:
		active = false
	
	if bracing_timer > 0:
		bracing_timer -= delta

	if active:
		var relative_position = global_position - player.global_position
		var movement_direction = relative_position.cross(Vector3.UP).normalized()
		

		target_strafing_velocity = max_strafing_velocity
		if not clockwise:
			target_strafing_velocity = -max_strafing_velocity
			
		var strafing_movement = movement_direction * target_strafing_velocity
			
		bracer_arm.look_at(bracer_arm.global_position + strafing_movement)
		
		if not swapping_direction:
			if movement_raycast.is_colliding():
				swapping_direction = true
				clockwise = !clockwise
		else:		
			if sign(strafing_velocity) == sign(target_strafing_velocity):
				swapping_direction = false
	
		strafing_velocity = move_toward(strafing_velocity, target_strafing_velocity, 15 * delta)
		
		move_and_collide(movement_direction * strafing_velocity * delta)
		var bracing_mult = -1.0
		if bracing_timer > 0:
			bracing_mult = 2.0
		var collision_data = move_and_collide(bracing_mult * aproach_speed * relative_position.normalized() * delta)
		if collision_data != null:
			var collider = collision_data.get_collider()
			if collider.is_in_group("player"):
				collider.take_damage()
				collider.velocity += Vector3.UP
				bracing_timer = 2.0


func take_damage():
	bloat_body.set_shader_parameter("red", 1.0);
	bloat_cloud.set_shader_parameter("red", 1.0);
	health -= 1
