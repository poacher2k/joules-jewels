extends KinematicBody2D

const gravity = 20
export var WALL_VELOCITY_BOUNCE_STEAL = 1000
export var MIN_VELOCITY_FOR_DAMAGE = 250
export var MAX_SPEED = 750

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
var prev_velocity = Vector2.ZERO
var is_alive = true
var is_flipped = false
var is_picked_up = false
var joules = null
export var pickup_type = "enemy1"

onready var initial_speed = speed
onready var MIN_VELOCITY_FOR_DAMAGE_SQ = MIN_VELOCITY_FOR_DAMAGE * MIN_VELOCITY_FOR_DAMAGE

func _ready():
	if not is_picked_up:
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

func pickup():
	is_picked_up = true
	flip()
	$CollisionShape2D.disabled = true


func throw(initial_velocity):
	velocity = initial_velocity
	$PickupArea.set_collision_mask_bit(0, false)
	$ThrowToPickupTimer.autostart = true

func _physics_process(delta):
	if not is_alive or is_picked_up:
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
	elif not is_flipped:
		velocity.x += speed * direction
		velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)

	if is_on_floor():
		velocity.x = lerp(velocity.x, 0, 0.1)


	velocity = move_and_slide(velocity, Vector2.UP)

func flip():
	is_flipped = true
	$AnimatedSprite.stop()
	$AnimatedSprite.flip_v = true
	set_collision_layer_bit(4, false)
	set_collision_mask_bit(4, false)

func unflip():
	is_flipped = false
	$AnimatedSprite.play("crawl")
	$AnimatedSprite.flip_v = false
	set_collision_layer_bit(4, true)
	set_collision_mask_bit(4, true)

func can_pickup():
	return not is_picked_up

func _on_top_checker_body_entered(body):
	if is_flipped:
		return

	if not is_jumpable:
		body.take_damage(position.x)
		return

	take_damage()

func force_bounce(bounciness):
	velocity.y = bounciness

func _on_sides_checker_body_entered(body):
	if is_flipped:
		return

	if does_damage and body.has_method("take_damage"):
		body.take_damage(position.x)

func _on_bottom_checker_body_entered(body):
	if is_flipped:
		return

	if does_damage and body.has_method("take_damage"):
		body.take_damage(position.x)

func _on_Timer_timeout():
	if is_invulnv:
		speed = initial_speed
		$AnimatedSprite.play("crawl")
		unflip()
	else:
		queue_free()

func take_damage():
#	if $AnimatedSprite.frames.has_animation("squashed"):
#		$AnimatedSprite.play("squashed")

	$AnimatedSprite.stop()

	if not is_invulnv:
		$CollisionShape2D.queue_free()
		$floor_checker.queue_free()
		$top_checker.queue_free()
		$sides_checker.queue_free()
		$bottom_checker.queue_free()

		is_alive = false

	if not move_while_squished:
		speed = 0

	flip()
	$Timer.start()


func _on_PickupArea_body_entered(body):
	if not is_flipped:
		return

	if can_pickup() and body.name == "Joules":
		joules = body
		joules.pickup(self)
	elif body.is_in_group("enemies") and velocity.length_squared() >= MIN_VELOCITY_FOR_DAMAGE_SQ:
		body.take_damage()

func _on_PickupArea_body_exited(body):
	if not is_flipped:
		return

	if body.name == "Joules":
		joules = null


func _on_ThrowToPickupTimer_timeout():
	$PickupArea.set_collision_mask_bit(0, true)
