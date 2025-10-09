extends Area2D


func _ready() -> void:
	self.body_entered.connect(bounced_on)


func bounced_on(body):
	if body.name == "Player":
		$AnimatedSprite2D.play("jump")
		await $AnimatedSprite2D.animation_finished
		$AnimatedSprite2D.play("idle")
