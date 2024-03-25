extends Area3D

var health = 3

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player = get_tree().get_first_node_in_group("player")
	
	var movement_direction = (player.global_transform.origin - global_transform.origin).normalized()
	global_transform.origin += movement_direction * delta
	
	if health <= 0:
		queue_free()
	
func take_damage():
	health -= 1

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.infect_adware()
		queue_free()
