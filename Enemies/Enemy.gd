extends KinematicBody2D

const gravity = 20

export var speed = 50
export var direction = -1
export var detects_cliffs = true
export var bounciness = -770
export var is_invulnv = false
export var is_static = false
export var move_while_squished = false
export var is_floating = false
export var no_modulate = false
export var is_jumpable = true
export var does_damage = true


var velocity = Vector2(0, 0)
var is_alive = true
onready var initial_speed = speed

func _ready():
	$AnimatedSprite.play()
	if direction == 1:
		$AnimatedSprite.flip_h = true

	$floor_checker.position.x = $CollisionShape2D.shape.get_extents().x * direction
	$floor_checker.enabled = detects_cliffs

	if no_modulate:
		return

	if detects_cliffs:
		set_modulate(Color.hotpink)

	if is_invulnv:
		set_modulate(Color.black)

func _physics_process(delta):
	if not is_alive:
		return

	if is_on_wall() or (detects_cliffs and not $floor_checker.is_colliding() and is_on_floor()):
		direction *= -1
		$AnimatedSprite.flip_h = not $AnimatedSprite.flip_h
		$floor_checker.position.x *= -1

	if is_floating:
		velocity.y = 0
	else:
		velocity.y += gravity

	if is_static:
		velocity.x = 0
	else:
		velocity.x = speed * direction

	velocity = move_and_slide(velocity, Vector2.UP)


func _on_top_checker_body_entered(body):
	if not is_jumpable:
		body.take_damage(position.x)
		return


	if $AnimatedSprite.frames.has_animation("squashed"):
		$AnimatedSprite.play("squashed")

	if not is_invulnv:
		$CollisionShape2D.queue_free()
		$floor_checker.queue_free()
		$top_checker.queue_free()
		$sides_checker.queue_free()
		$bottom_checker.queue_free()

		is_alive = false

	if not move_while_squished:
		speed = 0

	$Timer.start()

func force_bounce(bounciness):
	velocity.y = bounciness

func _on_sides_checker_body_entered(body):
	if does_damage:
		body.take_damage(position.x)

func _on_bottom_checker_body_entered(body):
	if does_damage:
		body.take_damage(position.x)

func _on_Timer_timeout():
	if is_invulnv:
		speed = initial_speed
		$AnimatedSprite.play("crawl")
	else:
		queue_free()


