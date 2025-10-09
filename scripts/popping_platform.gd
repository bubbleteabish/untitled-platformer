extends Area2D

var bounce_count := 0
const MAX_BOUNCE := 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.body_entered.connect(bounced_on)

 
func bounced_on(body):
	if body.name == "Player":
		bounce_count += 1
		modulate = Color.RED
	if bounce_count > MAX_BOUNCE:
		get_parent().remove_platform(self)
