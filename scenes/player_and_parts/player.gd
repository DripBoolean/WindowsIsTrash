extends CharacterBody3D

var camera_rotation = Vector2(0, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity = Vector3(10, 0, 0).rotated(Vector3(0, 1, 0), camera_rotation.x + PI / 2)
	move_and_slide()
	

func _input(event):
	if event is InputEventMouseMotion:
		camera_rotation += event.relative * -0.05
		camera_rotation.y = clamp(camera_rotation.y, -PI / 2, PI / 2)
		$Camera.transform.basis = Basis() # reset rotation
		$Camera.rotate_object_local(Vector3(0, 1, 0), camera_rotation.x)
		$Camera.rotate_object_local(Vector3(1, 0, 0), camera_rotation.y)
	
		
