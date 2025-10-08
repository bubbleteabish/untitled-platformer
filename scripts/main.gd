extends Node

var stump_scene = preload("res://scenes/stump.tscn")
var rock_scene = preload("res://scenes/rock.tscn")
var barrel_scene = preload("res://scenes/barrel.tscn")
var bird_scene = preload("res://scenes/bird.tscn")
var obstacle_types := [stump_scene, rock_scene, barrel_scene]
var obstacles : Array
var bird_heights := [200,390]

const DION_START_POS := Vector2i(150,485)
const CAM_START_POS := Vector2i(576,324)
var difficulty : int
const MAX_DIFFICULTY : int = 2
var score : int
const SCORE_MOD := 10
var high_score : int
var speed : int
const START_SPEED : int = 4
const SPEED_MODIFIER : int = 10000
const MAX_SPEED : int = 15
var screen_size : Vector2i
var ground_height : int
const X_BUFFER := 100
const Y_BUFFER := 5
var game_running : bool
var last_obs

func _ready() -> void:
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	$GameOver.get_node("Button").pressed.connect(new_game)
	new_game()

func new_game():
	score = 0
	show_score()
	game_running = false
	difficulty = 0
	get_tree().paused = false
	
	for obs in obstacles:
		remove_obs(obs)
	
	$Dino.position = DION_START_POS
	$Dino.velocity = Vector2i.ZERO
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i.ZERO
	$HUD.get_node("StartLabel").show()
	$GameOver.hide()

func _process(_delta: float) -> void:
	if game_running:
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficulty()
		
		generate_obs()
		
		$Dino.position.x += speed
		$Camera2D.position.x += speed
		
		score += speed
		show_score()

		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x
			
		for obs in obstacles:
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
		
	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			$HUD.get_node("StartLabel").hide()

func generate_obs():
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300, 500):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs 
		var max_obs = difficulty + 1
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = screen_size.x + score + X_BUFFER + (i * X_BUFFER)
			var obs_y : int = screen_size.y - ground_height - (obs_height * obs_scale.y / 2) + Y_BUFFER
			last_obs = obs
			add_obs(obs, obs_x, obs_y)
		if difficulty == MAX_DIFFICULTY:
			if (randi() % 2) == 0:
				obs = bird_scene.instantiate()
				var obs_x : int = screen_size.x + score + X_BUFFER
				var obs_y : int = bird_heights[randi() % bird_heights.size()]
				add_obs(obs, obs_x, obs_y)

func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)
	
func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)

func hit_obs(body):
	if body.name == "Dino":
		game_over()

func show_score():
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score / SCORE_MOD)

func check_high_score():
	if score > high_score:
		high_score = score
		$HUD.get_node("HighScoreLabel").text = "HIGH SCORE: " + str(high_score / SCORE_MOD)
	
func adjust_difficulty():
	difficulty = score / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY

func game_over():
	check_high_score()
	get_tree().paused = true
	game_running = false
	$GameOver.show()
