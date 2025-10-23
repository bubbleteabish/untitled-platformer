extends Area2D

signal hit_spikes

func _ready() -> void:
	self.body_entered.connect(bounced_on)


func bounced_on(body):
	if body is CharacterBody2D:
		var character_body = body as CharacterBody2D
		if character_body.velocity.y >= 0:
			hit_spikes.emit()
