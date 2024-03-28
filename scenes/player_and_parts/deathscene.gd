extends Node2D

var tick_time = 0.5
var elapsed = 0.0
var progress = 0

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	elapsed += delta
	if elapsed > tick_time:
		elapsed -= tick_time
		progress += randi_range(0, 15)
		if progress > 100:
			get_tree().quit()
			return
		$CompletionValue.set_text("%d%% Complete" % progress)
