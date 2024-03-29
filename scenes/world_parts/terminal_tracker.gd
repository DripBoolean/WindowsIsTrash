extends Node

var winscreen = preload("res://scenes/player_and_parts/winscene.tscn")

var won = false

func _process(_delta):
	if won:
		return
	for node in get_tree().get_nodes_in_group("progress"):
		if not node.complete():
			return

	won = true
	add_child(winscreen.instantiate())
