extends Node

func _process(_delta):
	for node in get_tree().get_nodes_in_group("progress"):
		if not node.complete():
			return
	get_tree().change_scene_to_file("res://scenes/player_and_parts/winscene.tscn")
