extends AnimatableBody2D


@export var duration = 5.0

func _ready():
	start_tween()

func start_tween():
	var tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_loops().set_parallel(false)
	var max_right = Vector2(get_window().size.x - 100, global_position.y)
	var max_left = Vector2(0, global_position.y)
	tween.tween_property(self, "global_position", max_left, duration /2)
	tween.tween_property(self, "global_position", max_right, duration /2)
	tween.bind_node(self)
