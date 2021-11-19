extends Area2D


export(String) var displayText = "" setget set_text
export(float) var collisionRadius = 86

func _ready():
	$CollisionShape2D.shape.radius = collisionRadius

func _on_ProximityText_body_entered(body):
	$AnimationPlayer.play("FadeIn")


func _on_ProximityText_body_exited(body):
	$AnimationPlayer.play("FadeOut")

func set_text(value):
	displayText = value
	$Label.text = value
