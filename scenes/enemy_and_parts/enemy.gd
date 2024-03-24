extends Node3D

var health = 3

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player = get_tree().get_nodes_in_group("player")[0]
	
	var movement_direction = (player.global_transform.origin - global_transform.origin).normalized()
	global_transform.origin += movement_direction * delta
	
	if health <= 0:
		queue_free()
	
func take_damage():
	health -= 1
