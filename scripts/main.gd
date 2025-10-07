extends Node

const DION_START_POS := Vector2i(150,485)
const CAM_START_POS := Vector2i(576,324)
var score : int
const SCORE_MOD := 10
var speed : float
const START_SPEED : float = 10.0
const MAX_SPEED : int = 25
var screen_size : Vector2i
var game_running : bool

func _ready() -> void:
	screen_size = get_window().size
	new_game()

func new_game():
	score = 0
	show_score()
	game_running = false
	
	$Dino.position = DION_START_POS
	$Dino.velocity = Vector2i.ZERO
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i.ZERO
	$HUD.get_node("StartLabel").show()

func _process(delta: float) -> void:
	if game_running:
		speed = START_SPEED
		
		$Dino.position.x += speed
		$Camera2D.position.x += speed
		
		score += speed
		show_score()

		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x
	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			$HUD.get_node("StartLabel").hide()

func show_score():
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score / SCORE_MOD)
