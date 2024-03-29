extends Area3D

var health = 3
@onready var sprite: Sprite3D = $Sprite3D
@onready var color: Color = Color(1.0, 1.0, 1.0, 1.0)
@onready var death_particle = preload("res://scenes/enemy_and_parts/malware_death.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player = get_tree().get_first_node_in_group("player")
	
	var movement_direction = (player.global_transform.origin - global_transform.origin).normalized()
	global_transform.origin += movement_direction * delta
	
	if color.b < 1.0:
		color.b += 1.0 * delta
		color.g += 1.0 * delta
	
	if health <= 0:
		explode()
		queue_free()
		
	sprite.modulate = color
	
func take_damage():
	health -= 1
	$sfx.play()
	color = Color(1.0, 0.0, 0.0, 1.0)
	sprite.modulate = color

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.infect_adware()
		queue_free()
		
func explode():
	var particle = death_particle.instantiate()
	get_node("/root/Main").add_child(particle)
	particle.global_position = self.global_position
	particle.get_child(0).emitting = true
