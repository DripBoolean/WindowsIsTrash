extends CanvasGroup

var rng = RandomNumberGenerator.new()

var text_options = ["A New Windows Update Is Available", "lmao gay"]

func _ready():
	$Button.pressed.connect(self.close)
	var own_size = $TextureRect.get_global_rect().size
	position = Vector2(rng.randf_range(0, get_viewport_rect().size.x - own_size.x), rng.randf_range(0, get_viewport_rect().size.y - own_size.y))
	$Text.add_text(text_options[rng.randi_range(0, text_options.size() - 1)])
	
func close():
	queue_free()
