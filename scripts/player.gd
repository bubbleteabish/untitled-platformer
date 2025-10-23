extends CharacterBody2D


const SPEED = 350.0
const JUMP_VELOCITY = -800.0
const TRAMP_VELOCITY = -1400.0

var start_jumping := false
var rotation_speed := 260
var object_hit

func _ready() -> void:
	$Area2D.body_entered.connect(hit_object)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and start_jumping == false:
		velocity.y = JUMP_VELOCITY
		start_jumping = true
	
	if start_jumping and is_on_floor():
		if object_hit == "TrampCol":
			velocity.y = TRAMP_VELOCITY
		else:
			velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction_x := Input.get_axis("ui_left", "ui_right")
	if direction_x:
		velocity.x = direction_x * SPEED
		if direction_x < 0:
			$Sprite2D.rotation_degrees -= rotation_speed * delta
		else:
			$Sprite2D.rotation_degrees += rotation_speed * delta
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func hit_object(body):
	object_hit = body.name
