extends KinematicBody2D

export var SPEED = Vector2(200.0, 1000.0)
export var MAX_SPEED = 1000
export var GROUND_FRICTION = 0.1
export var WALK_ANIMATION_THRESHOLD = 50
export var GRAVITY = 35
export var THROW_FORCE = Vector2(1000.0, 200.0)
export var INVULN_TIME_MS = 250
export var health = 3
const JUMP_FORCE = -1100
const FLOOR_DETECT_DISTANCE = 20.0
const FLOOR_NORMAL = Vector2.UP

export (NodePath) var joystickPath
onready var joystick: Joystick = get_node(joystickPath)

export (NodePath) var jumpBtnPath
onready var jumpBtn: JumpBtnJoystick = get_node(jumpBtnPath)

export (NodePath) var pickupsParentPath
onready var pickupsParent = get_node(pickupsParentPath)

onready var platform_detector = $PlatformDetector
onready var pickup_hold = $PickupHold
onready var throw_pos = $ThrowPos

export(float) var COYOTE_TIME_MS = 50
var velocity = Vector2(0, 0)
var gravity_direction = 1
var is_alive = true
var face_direction = 1

var last_touched_ground = 0
var last_damaged_at = 0

export(float) var MIN_THROW_PICKUP_DELAY = 200

var current_pickup_type = null
var current_pickup_instance = null

const PICKUP_SCENE = preload("res://Pickup.tscn")
const ENEMY1_SCENE = preload("res://Enemies/Enemy.tscn")
const GREEN_ENEMY_SCENE = preload("res://Enemies/GreenEnemy.tscn")

onready var pickup_types = {
	"pickup": PICKUP_SCENE,
	"enemy1": ENEMY1_SCENE,
	"greenEnemy": GREEN_ENEMY_SCENE
}

signal health_updated

func _ready():
	jumpBtn.connect("touch_started", self, "jump")
	$Timer.wait_time = INVULN_TIME_MS / 1000


func _physics_process(_delta):
	if Input.is_action_just_pressed("restart"):
		reset_scene()
		return

#	if joystick and joystick.is_working:
#		velocity.x = joystick.output.x * SPEED
#		$Sprite.play("walk")
#		$Sprite.flip_h = true if velocity.x < 1 else false

	velocity.y = velocity.y + GRAVITY * gravity_direction

	# Play jump sound
	if Input.is_action_just_pressed("jump") and is_on_floor():
		$JumpAudio.play()

	var now = OS.get_system_time_msecs()
	if is_on_floor():
		last_touched_ground = now

	var direction = get_direction()

	var is_jump_interrupted = Input.is_action_just_released("jump") and velocity.y < 0.0
	velocity = calculate_move_velocity(velocity, direction, SPEED, is_jump_interrupted)

	if is_on_floor():
		if abs(velocity.x) >= WALK_ANIMATION_THRESHOLD:
			if current_pickup_instance:
				$Sprite.play("walk_pickup")
			else:
				$Sprite.play("walk")
		else:
			if current_pickup_instance:
				$Sprite.play("idle_pickup")
			else:
				$Sprite.play("idle")
	else:
		if current_pickup_instance:
			$Sprite.play("jump_pickup")
		else:
			$Sprite.play("jump")

	if current_pickup_instance:
		if Input.is_action_just_pressed("fire"):
			throw()

	var snap_vector = Vector2.ZERO
	if direction.y == 0.0:
		snap_vector = Vector2.DOWN * FLOOR_DETECT_DISTANCE
	var is_on_platform = platform_detector.is_colliding()
	velocity = move_and_slide_with_snap(
		velocity, snap_vector, FLOOR_NORMAL, not is_on_platform, 4, 0.9, false
	)

	if direction.x != 0 and direction.x != face_direction:
		$Sprite.flip_h = direction.x == -1
		face_direction = direction.x
		throw_pos.position.x *= -1

func pickup(collisionBody):
	if current_pickup_instance:
		return

	collisionBody.is_picked_up = true
	collisionBody.call_deferred("queue_free")

	var type = pickup_types.get(collisionBody.pickup_type)

	var newChild = type.instance()
	newChild.pickup()
	pickup_hold.call_deferred("add_child", newChild)
	current_pickup_type = type
	current_pickup_instance = newChild


func throw():
	var direction = get_direction()
	var newChild = current_pickup_type.instance()
	newChild.position = throw_pos.global_position

	var initial_velocity = velocity
	initial_velocity.x = (abs(velocity.x) + THROW_FORCE.x) * direction.x
	initial_velocity.y += -THROW_FORCE.y
	if face_direction == 1:
		initial_velocity.x = max(initial_velocity.x, THROW_FORCE.x)
	else:
		initial_velocity.x = min(initial_velocity.x, -THROW_FORCE.x)

	newChild.throw(initial_velocity)

	pickupsParent.call_deferred("add_child", newChild)
	current_pickup_instance.call_deferred("queue_free")
	current_pickup_type = null
	current_pickup_instance = null

	if not $ThrowAudio.playing:
		$ThrowAudio.play()


# This function calculates a new velocity whenever you need it.
# It allows you to interrupt jumps.
func calculate_move_velocity(
		linear_velocity,
		direction,
		speed,
		is_jump_interrupted
	):

	var velocity = linear_velocity
	velocity.x += speed.x * direction.x
	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
	velocity.x = lerp(velocity.x, 0, GROUND_FRICTION)
	if direction.y != 0.0:
		velocity.y = speed.y * direction.y
	if is_jump_interrupted:
		# Decrease the Y velocity by multiplying it, but don't set it to 0
		# as to not be too abrupt.
		velocity.y *= 0.6
	return velocity


func get_direction():
	var on_floor_or_coyote = is_on_floor() or (OS.get_system_time_msecs() - last_touched_ground) <= COYOTE_TIME_MS

	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		-1 if on_floor_or_coyote and Input.is_action_just_pressed("jump") else 0
	)


func reset_scene():
	get_tree().reload_current_scene()
	Global.reset()


func jump():
	if is_on_floor():
		velocity.y = JUMP_FORCE * gravity_direction


func _on_Fallzone_body_entered(_body):
	reset_scene()


func bounce(bounciness):
	velocity.y += bounciness
	print("Bounce!")


func force_bounce(bounciness):
	velocity.y = bounciness
	print("Force Bounce!")


func side_force_bounce(bounciness):
	velocity.x = bounciness
	print("Side Force Bounce!")


func take_damage(enemyPosition: float):
	if not is_alive:
		return

	var now = OS.get_system_time_msecs()

	if now - last_damaged_at <= INVULN_TIME_MS:
		return

	print("Take damage!")
	health -= 1
	emit_signal("health_updated", health)
	set_modulate(Color(1, 0.3, 0.3, 0.3))

	if health > 0:
		$HurtAudio.play()
		last_damaged_at = now
	else:
		is_alive = false
		$DeathAudio.play()


	$Timer.start()

	var direction = -1 if enemyPosition > position.x else 1
	velocity.y += JUMP_FORCE * 0.3
	velocity.x += 800 * direction


func _on_Timer_timeout():
	if is_alive:
		set_modulate(Color.white)
	else:
		reset_scene()


func _on_FocusTimer_timeout():
	var window = JavaScript.get_interface("window")
	if window:
		window.focus()
	$FocusTimer.start()
