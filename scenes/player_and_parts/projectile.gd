extends Node3D

var velocity = Vector2(0, 0)

func _process(delta):
	position += velocity * delta
	
