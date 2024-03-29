extends Area3D

var health = 3
@onready var sprite: Sprite3D = $Sprite3D
@onready var color: Color = Color(1.0, 1.0, 1.0, 1.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player = get_tree().get_first_node_in_group("player")
	
	var movement_direction = (player.global_transform.origin - global_transform.origin).normalized()
	global_transform.origin += movement_direction * delta
	
	if color.b < 1.0:
		color.b += 1.0 * delta
		color.g += 1.0 * delta
	
	if health <= 0:
		queue_free()
		
	sprite.modulate = color
	
func take_damage():
	health -= 1
	color = Color(1.0, 0.0, 0.0, 1.0)
	sprite.modulate = color

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.infect_adware()
		queue_free()
