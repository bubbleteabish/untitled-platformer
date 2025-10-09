extends Node

var standard_platform = preload("res://scenes/standard_platform.tscn")
var popping_platform = preload("res://scenes/popping_platform.tscn")
var trampoline = preload("res://scenes/trampoline.tscn")
var spikes = preload("res://scenes/spikes.tscn")

var platforms : Array
var obstacles : Array
var screen_size : Vector2i
var cam_limit : int

var standard_dict := {"acc_weight":0, "roll_weight":20,"index":0,"diff":1, "type":"platform"}
var popping_dict := {"acc_weight":0, "roll_weight":0, "index":1,"diff":1, "type":"platform"}
var trampoline_dict := {"acc_weight":0, "roll_weight":0, "index":2,"diff":2, "type":"platform"}
var spikes_dict := {"acc_weight":0, "roll_weight":0, "index":0,"diff":1, "type":"obstacle"}
var platform_types := [standard_platform, popping_platform, trampoline]
var obstacle_types := [spikes]
var dicts := [standard_dict, popping_dict, trampoline_dict, spikes_dict]
var platform_weight : int
var obstacle_weight : int

var last_platform
var last_platform_type : String
var score : int
var player_start_pos : Vector2i
var easy_diff : int
var medium_diff : int

var platform_count := 0

const MAX_DIFFICULTY := 20
const MAX_PLATFORMS := 15
const MAX_OBSTACLES := 20

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size
	easy_diff = -(screen_size.x * 2)
	medium_diff = -(screen_size.x * 6)
	player_start_pos = $Player.global_position
	$GameOver.get_node("Button").pressed.connect(new_game)
	new_game()

func new_game():
	$Player.global_position = player_start_pos
	$Player/Camera2D.limit_bottom = screen_size.y
	for platform in platforms:
		platform.queue_free()
	for obstacle in obstacles:
		obstacle.queue_free()
	for obj in dicts:
		if obj.type == "platform":
			if obj.index == 0:
				obj.roll_weight = 20
			else:
				obj.roll_weight = 0
	platforms.clear()
	obstacles.clear()
	last_platform = $Platform4
	last_platform_type = "Platform"
	score = player_start_pos.y
	cam_limit = $Player/Camera2D.global_position.y
	$GameOver.hide()
	get_tree().paused = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if $Player.global_position.y > $Player/Camera2D.limit_bottom:
		game_over()
	if $Player/Camera2D.global_position.y < cam_limit:
		cam_limit = $Player/Camera2D.global_position.y
		$Player/Camera2D.limit_bottom = cam_limit + screen_size.y
	if $Player.global_position.y < score:
		score = $Player.global_position.y
	
	if score <= easy_diff and score >= medium_diff:
		for obj in dicts:
			if obj.type == "platform":
				if obj.diff == 1:
					obj.roll_weight = 20
				elif obj.diff == 2:
					obj.roll_weight = 5
	generate_platforms()
	
	for platform in platforms:
		if platform.position.y >= cam_limit + screen_size.y:
			remove_platform(platform)
	for obstacle in obstacles:
		if obstacle.position.y >= cam_limit + screen_size.y:
			remove_obstacle(obstacle)
	#generate_platforms()
	#print(str(score) + " : " + str(last_platform.global_position.y))


func generate_platforms():
	if platforms.is_empty() or platforms.size() < MAX_PLATFORMS:
		init_probabilities()
		var i = pick_object("platform")
		var random_platform = platform_types[i]
		var platform = random_platform.instantiate()
		var platform_length = platform.get_node("Sprite2D").texture.get_width()
		var platform_scale = platform.scale
		platform_length = platform_length * platform_scale.x
		#var platform_length = platform.get_node("TileMapLayer").map_to_local(platform_rect.size).x
	#	var platform_height = platform.get_node("TileMapLayer").texture.get_height()
		var platform_x : int
		var offset : int = (screen_size.x / 2)
		if last_platform.global_position.x < offset:
			platform_x = clamp(randi_range(offset, screen_size.x ),offset, screen_size.x - platform_length)
		else:
			platform_x = clamp(randi() % offset, 0, screen_size.x - platform_length)
		var platform_y : int
		if last_platform_type == "Trampoline":
			platform_y = last_platform.global_position.y - randi_range(600,775)
		else:
			platform_y = last_platform.global_position.y - randi_range(175,275)
		last_platform_type = platform.name
		last_platform = platform
		platform_count += 1
		if last_platform_type == "StandardPlatform":
			print(str(platform_count) + ":" + str(platform_x) + " " + str(platform_y))
			var obs_chance := randi_range(1,4)
			if obs_chance == 4:
				var obs_index = pick_object("obstacle")
				var random_obs = obstacle_types[obs_index]
				var obs = random_obs.instantiate()
				var obs_length = obs.get_node("Sprite2D").texture.get_width() * obs.scale.x
				var obs_x = randi_range(platform_x, platform_x + platform_length - obs_length)
				add_obstacle(obs, obs_x, platform_y)
		add_platform(platform, platform_x, platform_y)

func init_probabilities() -> void:
   # Reset total_weight to make sure it holds the correct value after initialization
	platform_weight = 0
	obstacle_weight = 0
   # Iterate through the objects
	for obj in dicts:
	  # Take current object weight and accumulate it
		if obj.type == "platform":
			platform_weight += obj.roll_weight
	  # Take current sum and assign to the object.
			obj.acc_weight = platform_weight
		if obj.type == "obstacle":
			obstacle_weight += obj.roll_weight
			obj.acc_weight = obstacle_weight
		
func pick_object(type : String) -> int:
	var roll
	if type == "platform":
		roll = randf_range(0.0, platform_weight)
		for platform in dicts:
			if platform.type == "platform" and platform.acc_weight > roll:
				return platform.index
	if type == "obstacle":
		roll = randf_range(0.0, obstacle_weight)
		for obstacle in dicts:
			if obstacle.type == "obstacle" and obstacle.acc_weight > roll:
				return obstacle.index
	return -1

func add_platform(platform, x, y):
	platform.global_position = Vector2i(x,y)
	add_child(platform)
	platforms.append(platform)

func add_obstacle(obstacle, x, y):
	obstacle.global_position = Vector2i(x,y)
	add_child(obstacle)
	obstacles.append(obstacle)

func remove_platform(platform):
	platform.queue_free()
	platforms.erase(platform)

func remove_obstacle(obstacle):
	obstacle.queue_free()
	obstacles.erase(obstacle)
	
func game_over():
	get_tree().paused = true
	$GameOver.show()

func test():
	print("TEST")
