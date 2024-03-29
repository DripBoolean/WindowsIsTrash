extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$ost.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not $ost.playing:
		$ost.play()

func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_quit_pressed():
	get_tree().quit()


func _on_credits_pressed():
	get_tree().change_scene_to_file("res://scenes/credits.tscn")
