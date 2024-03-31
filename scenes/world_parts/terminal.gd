extends StaticBody3D

var linux_installed = false
var SPAWN_CHANCE_PER_INTERVAL = 0.3
var SPAWN_RANGE_HORIZONTAL = 5.0
var SPAWN_RANGE_VERTICAL = 0.0
@onready var sprite = $Sprite3D
var linux = preload("res://textures/Linux_Background_Pixel.png")

var rng = RandomNumberGenerator.new()
var adware_scene = preload("res://scenes/enemy_and_parts/enemy.tscn")

func _ready():
	$SpawnTimer.start()


func _process(_delta):
	if linux_installed:
		$Light.light_color = Color(0, 150, 0)
	else:
		$Light.light_color = Color(0, 0, rng.randi_range(100, 150))

func activate():
	$sfx.play()
	linux_installed = true
	sprite.texture = linux
	print("ACTIVE")

func complete():
	return linux_installed

func _on_spawn_timer_timeout():
	if not $ActiveArea.overlaps_body(get_tree().get_first_node_in_group("player")):
		return
	if rng.randf_range(0, 1) < SPAWN_CHANCE_PER_INTERVAL:
		var adware_instance = adware_scene.instantiate()
		adware_instance.position = Vector3(
			rng.randf_range(-SPAWN_RANGE_HORIZONTAL, SPAWN_RANGE_HORIZONTAL),
			rng.randf_range(-SPAWN_RANGE_VERTICAL, SPAWN_RANGE_VERTICAL),
			rng.randf_range(-SPAWN_RANGE_HORIZONTAL, SPAWN_RANGE_HORIZONTAL)
			)
		add_child(adware_instance)
		
