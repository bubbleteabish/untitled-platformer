extends Area2D


func _ready() -> void:
	self.body_entered.connect(bounced_on)


func bounced_on(body):
	if body is CharacterBody2D:
		var character_body = body as CharacterBody2D
		if character_body.velocity.y == 0 or character_body.velocity.y == body.TRAMP_VELOCITY:
			$AnimatedSprite2D.play("jump")
			await $AnimatedSprite2D.animation_finished
			$AnimatedSprite2D.play("idle")
