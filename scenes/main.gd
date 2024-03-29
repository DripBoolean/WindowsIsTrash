extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	$ost.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not $ost.playing:
		$ost.play()
