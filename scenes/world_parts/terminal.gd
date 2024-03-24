extends StaticBody3D

var linux_installed = false

func _process(delta):
	if linux_installed:
		$Light.light_color = Color(0, 255, 0)
	else:
		$Light.light_color = Color(255, 0, 0)

func activate():
	linux_installed = true
	print("ACTIVE")
