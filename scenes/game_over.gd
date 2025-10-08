extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset_trans()



func _on_button_mouse_entered() -> void:
	$Button.modulate = Color(1,1,1,1)


func _on_button_mouse_exited() -> void:
	reset_trans()

func reset_trans():
	$Button.modulate = Color(1,1,1,.5)
