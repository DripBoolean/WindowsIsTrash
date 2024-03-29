extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print("hello?")
	for node in get_tree().get_nodes_in_group("progress"):
		if not node.complete():
			print("unfished")
			return
	print("Got all of them yay!")
