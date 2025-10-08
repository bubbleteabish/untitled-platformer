extends Node

var standard_platform = preload("res://scenes/platform.tscn")
var popping_platform = preload("res://scenes/popping_platform.tscn")

var platforms : Array
var screen_size : Vector2i
var cam_limit : int
var platform_types := [standard_platform, popping_platform]

var last_platform
var score : int
var player_start_pos : Vector2i
var difficulty : int
var easy : int
var medium : int

const MAX_DIFFICULTY := 3
const MAX_PLATFORMS := 15

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size
	difficulty = 0
	easy = -(screen_size.x * 2)
	medium = -(screen_size.x * 6)
	last_platform = $Platform4
	player_start_pos = $Player.global_position
	$GameOver.get_node("Button").pressed.connect(new_game)
	new_game()

func new_game():
	$Player.global_position = player_start_pos
	$Player/Camera2D.limit_bottom = screen_size.y
	for platform in platforms:
		platform.queue_free()
	platforms.clear()
	last_platform = $Platform4
	score = player_start_pos.y
	cam_limit = $Player/Camera2D.global_position.y
	difficulty = 0
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
	
	if score <= easy and score >= medium:
		difficulty = 1
	generate_platforms()
	
	for platform in platforms:
		if platform.position.y >= cam_limit + screen_size.y:
			remove_platform(platform)
	#generate_platforms()
	#print(str(score) + " : " + str(last_platform.global_position.y))

func generate_platforms():
	if platforms.is_empty() or platforms.size() < MAX_PLATFORMS:
		var platform
		var random_platform = platform_types[randi_range(0,difficulty)]
		platform = random_platform.instantiate()
		var platform_rect = platform.get_node("TileMapLayer").get_used_rect()
		var platform_length = platform.get_node("TileMapLayer").map_to_local(platform_rect.size).x
	#	var platform_height = platform.get_node("TileMapLayer").texture.get_height()
		var platform_x : int
		if last_platform.global_position.x < (screen_size.x / 2) - platform_length:
			platform_x = randi_range(screen_size.x / 2, screen_size.x - platform_length)
		else:
			var offset : int = (screen_size.x / 2) - platform_length
			platform_x = randi() % offset
		var platform_y : int = last_platform.global_position.y - randi_range(175,275)
		last_platform = platform
		add_platform(platform, platform_x, platform_y)

func add_platform(platform, x, y):
	platform.global_position = Vector2i(x,y)
	add_child(platform)
	platforms.append(platform)

func remove_platform(platform):
	platform.queue_free()
	platforms.erase(platform)
	
func game_over():
	get_tree().paused = true
	$GameOver.show()

func test():
	print("TEST")
