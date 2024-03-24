extends CharacterBody3D

@onready var d = get_node("../Destruction")

func shatter():
	print(d)
	d.destroy()
