extends Node3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player = get_tree().get_nodes_in_group("player")[0]
	
	var movement_direction = (player.global_position -global_position ).normalized()
	
	position += movement_direction * 0.02
	
	
