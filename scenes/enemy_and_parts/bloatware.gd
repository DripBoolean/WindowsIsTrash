extends CharacterBody3D

@onready var eyes = $Eyes
@onready var los = $Eyes/LineOfSightRaycast

var active = false
var clockwise = true

func _physics_process(delta):
	var player = get_tree().get_first_node_in_group("player")
	eyes.look_at(player.global_transform.origin, Vector3.UP)
	
	active = false
	if los.is_colliding():
		var collider = los.get_collider()
		if collider != null:
			if collider.is_in_group("player"):
				active = true
			
	
	
	if active:
		var relative_position = global_position - player.global_position
		var movement = relative_position.cross(Vector3.UP).normalized() * delta * 10
		movement += relative_position.normalized() * delta * 0.5
		print(movement)
		if clockwise:
			movement *= -1
		movement.y = 0

		if(move_and_collide(movement)):
			clockwise = !clockwise
			print("collided")
		
	
	
