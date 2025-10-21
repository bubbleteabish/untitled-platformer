extends Node

var moving_platform = preload("res://scenes/moving_platform.tscn")
var popping_platform = preload("res://scenes/popping_platform.tscn")
var trampoline = preload("res://scenes/trampoline.tscn")
var foam_platform = preload("res://scenes/foam_platform.tscn")
var spikes = preload("res://scenes/spikes.tscn")

var platforms : Array
var obstacles : Array
var screen_size : Vector2i
var cam_limit : int

var platform_types := [foam_platform, trampoline, popping_platform, moving_platform ]
var obstacle_types := [spikes]


var last_platform
var last_platform_type : String
var score : int
var display_score := 0
var high_score : int = 0
var player_start_pos : Vector2i
var current_difficulty := 0
var difficulties := []
var platform_gaps := Vector2i(0,0)

var platform_count := 0

const MAX_DIFFICULTY := 20
const MAX_PLATFORMS := 55
const MAX_OBSTACLES := 55
const MAX_GAP := 285

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size
	for diff in range(0,MAX_DIFFICULTY):
		difficulties.append(screen_size.x * pow(diff,3))
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
	platforms.clear()
	obstacles.clear()
	last_platform = $FoamPlatform9
	last_platform_type = "Platform"
	score = player_start_pos.y
	display_score = 0
	current_difficulty = 0
	platform_gaps = Vector2i(55,85)
	cam_limit = $Player/Camera2D.global_position.y
	$GameOver.hide()
	get_tree().paused = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if score < 0:
		display_score = -score
	else: display_score = max(score - player_start_pos.y, 0)
	if display_score > high_score:
		high_score = display_score
	$Hud/MarginContainer/HighScoreLabel.text = "High Score: " + str(high_score)
	$Hud.get_node("MarginContainer/ScoreLabel").text = "Score: " + str(display_score)
	if $Player.global_position.y > $Player/Camera2D.limit_bottom:
		game_over()
	if $Player/Camera2D.global_position.y < cam_limit:
		cam_limit = $Player/Camera2D.global_position.y
		$Player/Camera2D.limit_bottom = cam_limit + screen_size.y
	if $Player.global_position.y < score:
		score = $Player.global_position.y
	

	for diff in range(1,difficulties.size()-1):
		if display_score >= difficulties[diff] and display_score <= difficulties[diff+1] and current_difficulty != diff:
			current_difficulty = diff
			platform_gaps.y= min(platform_gaps.y + 10, MAX_GAP)
			print("CHANGE" + str(platform_gaps.y))
			diff += 1
	generate_platforms()
	
	for platform in platforms:
		if platform.position.y >= cam_limit + screen_size.y:
			remove_element(platform, "platform")
	for obstacle in obstacles:
		if obstacle.position.y >= cam_limit + screen_size.y:
			remove_element(obstacle, "obstacle")


func generate_platforms():
	if platforms.is_empty() or platforms.size() < MAX_PLATFORMS:
		var i = pick_object("platform")
		var random_platform = platform_types[i]
		var platform = random_platform.instantiate()
		var platform_length = platform.get_node("Sprite2D").texture.get_width()
		var platform_scale = platform.scale
		platform_length = platform_length * platform_scale.x
		var platform_x : int
		var offset : int = (screen_size.x / 2)
		if last_platform.global_position.x < offset:
			platform_x = clamp(randi_range(offset, screen_size.x ),offset, screen_size.x - platform_length)
		else:
			platform_x = clamp(randi() % offset, 0, screen_size.x - platform_length)
		var platform_y = last_platform.global_position.y - randi_range(platform_gaps.x,platform_gaps.y)
		last_platform_type = platform.name
		last_platform = platform
		platform_count += 1
		var obs_chance := randi_range(1,10)
		if obs_chance == 10:
			var obs_index = pick_object("obstacle")
			var random_obs = obstacle_types[obs_index]
			var obs = random_obs.instantiate()
			if obs.name == "Spikes":
				obs.hit_spikes.connect(game_over)
			var obs_length = obs.get_node("Sprite2D").texture.get_width() * obs.scale.x
			var obs_x = randi_range(platform_x, platform_x + platform_length - obs_length)
			add_element(obs, "obstacle", obs_x, platform_y)
		add_element(platform, "platform", platform_x, platform_y)

		
func pick_object(type : String) -> int:
	var roll
	if current_difficulty == 0:
		return 0
	else:
		if type == "platform":
			var roll_max = 85 - current_difficulty
			roll = randi_range(0,100)
			print(str(roll))
			if roll <= roll_max:
				return 0
			elif roll > 85 and roll <= 90:
				return 1
			else:
				roll = randi_range(2, platform_types.size()-1)
				return roll
		if type == "obstacle":
			return 0
	return -1

func add_element(element, type, x ,y):
	element.global_position = Vector2i(x,y)
	add_child(element)
	if type == "platform":
		platforms.append(element)
	elif type == "obstacle":
		obstacles.append(element)

func remove_element(element, type):
	element.queue_free()
	if type == "platform":
		platforms.erase(element)
	elif type == "obstacle":
		obstacles.erase(element)

	
func game_over():
	get_tree().paused = true
	$GameOver.show()
