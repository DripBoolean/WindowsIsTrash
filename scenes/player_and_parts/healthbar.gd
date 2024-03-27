extends ProgressBar

@onready var timer = $Timer
@onready var dmg = $damagebar
@onready var port = $player_image

# HEALTH SHAKE
@export var trauma_reduction_rate = 1.0
@export var max_x = 10.0
@export var max_y = 10.0
@export var noise = FastNoiseLite.new()
@export var noise_speed = 50.0
@onready var init_pos = self.global_position 
var trauma = 0.0
var time = 0.0


var health = 0: set = _set_health

func _set_health(new_health):
	var prev_health = health
	health = min(max_value, new_health)
	value = health
	trauma = 2.5
	port.set_color(Color(1.0, 0.0, 0.0, 1.0))
	
	if health <= 0:
		queue_free()
		
	if health < prev_health:
		timer.start()
	else:
		dmg.value = health
		
func get_shake_intensity() -> float:
	return pow(trauma, 2.0)
	
func get_noise_from_seed(_seed : int) -> float:
	noise.seed = _seed
	return noise.get_noise_1d(time * noise_speed)
		
func _process(delta):
	time += delta 
	trauma = max(trauma - delta * trauma_reduction_rate, 0.0)
	
	self.global_position.x = init_pos.x + max_x * get_shake_intensity() * get_noise_from_seed(0)
	self.global_position.y = init_pos.y + max_y * get_shake_intensity() * get_noise_from_seed(1)

func init_health(_health):
	health = _health
	max_value = health
	value = health
	dmg.max_value = health
	dmg.value = health
	trauma = 0.0
	port.set_color(Color(0.0, 1.0, 0.0, 1.0))

func _on_timer_timeout():
	dmg.value = health
	trauma = 0.0
	port.set_color(Color(0.0, 1.0, 0.0, 1.0))
