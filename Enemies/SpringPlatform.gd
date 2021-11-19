extends KinematicBody2D

export var bounciness = -770
export var vertical = true

func _ready():
	$AnimatedSprite.play("default")

func _on_top_checker_body_entered(body):
	$AnimatedSprite.play("spring")
	if vertical:
		body.force_bounce(bounciness)
	else:
		body.side_force_bounce(bounciness)


func _on_AnimatedSprite_animation_finished():
	$AnimatedSprite.play("default")
