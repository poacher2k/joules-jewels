extends KinematicBody2D

var velocity = Vector2.ZERO
export var GRAVITY = 35
export var FRICTION = 0.08

onready var collisionShape = $CollisionShape2D
var is_picked_up = false

func _physics_process(delta):
	if not is_picked_up:
		velocity.y = velocity.y + GRAVITY
		velocity = move_and_slide(velocity, Vector2.UP)

		if is_on_floor():
			velocity.x = lerp(velocity.x, 0, FRICTION)

func pickup():
	is_picked_up = true
	$CollisionShape2D.disabled = true

func throw(initial_velocity, direction):
	velocity = initial_velocity


func can_pickup():
	return not is_picked_up


func _on_Pickup_body_entered(body):
	print("Pickup!")
