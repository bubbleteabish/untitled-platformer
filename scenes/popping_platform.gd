extends Area2D

var bounce_count := 0
const MAX_BOUNCE := 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate = Color.GREEN
	self.body_entered.connect(bounced_on) # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func bounced_on(body):
	if body.name == "Player":
		bounce_count += 1
		match bounce_count:
			1: modulate = Color.YELLOW
			2: modulate = Color.RED
	if bounce_count > MAX_BOUNCE:
		get_parent().remove_platform(self)
 
