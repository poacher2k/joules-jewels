extends KinematicBody2D

export var GRAVITY = 35
export var FRICTION = 0.08
export var WALL_VELOCITY_BOUNCE_STEAL = 1000

onready var collisionShape = $CollisionShape2D
onready var throwToPickupTimer = $ThrowToPickupTimer

var is_picked_up = false
var velocity = Vector2.ZERO
var prev_velocity = Vector2.ZERO


func _physics_process(delta):
	if is_picked_up:
		return
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
	set_collision_layer_bit(4, false)
	set_collision_mask_bit(0, false)
	$ThrowToPickupTimer.autostart = true

func can_pickup():
	return not is_picked_up

func _on_ThrowToPickupTimer_timeout():
	set_collision_layer_bit(4, true)
	set_collision_mask_bit(0, true)
