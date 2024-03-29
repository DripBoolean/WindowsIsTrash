extends Node

var winscreen = preload("res://scenes/player_and_parts/winscene.tscn")

var won = false

func _process(_delta):
	if won:
		return
	
		
	
	var num_terminals = get_tree().get_nodes_in_group("progress").size()
	var num_completed = 0
	for node in get_tree().get_nodes_in_group("progress"):
		if node.complete():
			num_completed += 1
	
	
	$Node2D/ProgressBar.value = 100 * float(num_completed) / float(num_terminals)

	
	if num_completed == num_terminals:
		won = true
		add_child(winscreen.instantiate())
