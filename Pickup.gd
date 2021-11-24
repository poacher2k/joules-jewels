extends KinematicBody2D

var velocity = Vector2.ZERO
export var GRAVITY = 35

func _physics_process(delta):
	velocity.y = velocity.y + GRAVITY

	velocity = move_and_slide(velocity)

func _on_Pickup_body_entered(body):
	print("Pickup!")
