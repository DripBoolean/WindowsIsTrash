extends RigidBody3D

var bounces = 0


func _process(_delta):
	if self.get_contact_count() > 0:
		bounces += 1
	if bounces > 5:
		self.destroy()
	
func _on_body_entered(body):
	if body.is_in_group("enemy"):
		body.take_damage()
		self.destroy()
	elif body.is_in_group("glass"):
		body.shatter()

func destroy():
	self.queue_free()


func _on_area_3d_area_entered(area):
	if area.is_in_group("enemy"):
		area.take_damage()
		self.destroy()
