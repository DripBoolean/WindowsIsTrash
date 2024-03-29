extends Node2D

var close_time = 3.0

# Called when the node enters the scene tree for the first time.
func _ready():
	modulate.a = 0
	# Does not work :(
	RenderingServer.canvas_item_set_draw_index(get_canvas_item(), 100)
	RenderingServer.canvas_item_set_z_index(get_canvas_item(), 100)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	modulate.a += delta
	close_time -= delta
	
	if close_time < 0:
		get_tree().quit()
	
	
