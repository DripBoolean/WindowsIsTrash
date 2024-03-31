extends CanvasGroup

var rng = RandomNumberGenerator.new()

static var image_options = []
static var image_size = []
static var image_directory = "res://textures/popups/"

static func _static_init():
	for image_path in DirAccess.get_files_at(image_directory):
		if image_path.get_extension() == "png":
			var image = load(image_directory + image_path)
			image_options.append(image)
			image_size.append(image.get_size())
			print("Loading image: " + image_path)

func _ready():
	var image_choice = rng.randi_range(0, len(image_options)) - 1
	$TextureRect.texture = image_options[image_choice]
	$TextureRect.size = image_size[image_choice]
	
	var own_size = $TextureRect.get_global_rect().size
	print(own_size)
	
	$Button.pressed.connect(self.close)
	$Button.position = Vector2(own_size.x - $Button.get_global_rect().size.x - 5, 5)
	position = Vector2(rng.randf_range(0, get_viewport_rect().size.x - own_size.x), rng.randf_range(0, get_viewport_rect().size.y - own_size.y))
	
func close():
	queue_free()
