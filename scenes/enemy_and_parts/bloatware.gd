extends CharacterBody3D

@onready var eyes = $Eyes
@onready var los = $Eyes/LineOfSightRaycast
@onready var bracer_arm = $BracerArm
@onready var movement_raycast = $BracerArm/MovementRaycast

var active = false
var clockwise = true
var swapping_direction = false
var strafing_velocity = 0
var target_strafing_velocity = 0
var max_strafing_velocity = 5
var attention = 10

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
	
	if sees_player():
		attention = 10
		active = true
	else:
		attention -= delta
	
	if attention < 0:
		active = false
		print("chilling out")

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
