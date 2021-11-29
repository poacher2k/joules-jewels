extends KinematicBody2D

export var GRAVITY = 35
export var FRICTION = 0.08
export var WALL_VELOCITY_BOUNCE_STEAL = 1000
export var MIN_VELOCITY_FOR_DAMAGE = 250

onready var collisionShape = $CollisionShape2D
onready var throwToPickupTimer = $ThrowToPickupTimer
onready var pickupArea = $PickupArea
onready var MIN_VELOCITY_FOR_DAMAGE_SQ = MIN_VELOCITY_FOR_DAMAGE * MIN_VELOCITY_FOR_DAMAGE

var is_picked_up = false
var velocity = Vector2.ZERO
var prev_velocity = Vector2.ZERO
const pickup_type = "pickup"
var joules = null

func _physics_process(delta):
	if is_picked_up:
		return

	if joules != null:
		joules.pickup(self)

	prev_velocity = velocity

	velocity.y = velocity.y + GRAVITY

	velocity = move_and_slide(velocity, Vector2.UP)

	if is_on_wall():
		var velocity_after_bounce = abs(prev_velocity.x) - WALL_VELOCITY_BOUNCE_STEAL
		if velocity_after_bounce > 0:
			velocity.x = velocity_after_bounce * sign(prev_velocity.x) * -1

	if is_on_floor():
		velocity.x = lerp(velocity.x, 0, FRICTION)

func pickup():
	is_picked_up = true
	$CollisionShape2D.disabled = true

func throw(initial_velocity):
	velocity = initial_velocity
	$PickupArea.set_collision_mask_bit(0, false)
	$ThrowToPickupTimer.autostart = true

func can_pickup():
	return not is_picked_up

func _on_ThrowToPickupTimer_timeout():
	$PickupArea.set_collision_mask_bit(0, true)

func _on_PickupArea_body_entered(body):
	if can_pickup() and body.name == "Joules":
		joules = body
		joules.pickup(self)
	elif body.is_in_group("enemies") and velocity.length_squared() >= MIN_VELOCITY_FOR_DAMAGE_SQ:
		body.take_damage()

func _on_PickupArea_body_exited(body):
	if body.name == "Joules":
		joules = null
