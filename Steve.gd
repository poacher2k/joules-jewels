extends KinematicBody2D

export(String) var action_suffix = ""

export var SPEED = Vector2(200.0, 1000.0)
const GRAVITY = 35
const JUMP_FORCE = -1100
const FLOOR_DETECT_DISTANCE = 20.0
const FLOOR_NORMAL = Vector2.UP

export (NodePath) var joystickPath
onready var joystick: Joystick = get_node(joystickPath)

export (NodePath) var jumpBtnPath
onready var jumpBtn: JumpBtnJoystick = get_node(jumpBtnPath)

onready var platform_detector = $PlatformDetector

export(float) var COYOTE_TIME_MS = 100
var velocity = Vector2(0, 0)
var gravity_direction = 1
var is_alive = true

var last_touched_ground = 0

func _ready():
	jumpBtn.connect("touch_started", self, "jump")

	if Global.current_checkpoint != null:
		global_position = Global.current_checkpoint


func _physics_process(_delta):
#	if joystick and joystick.is_working:
#		velocity.x = joystick.output.x * SPEED
#		$Sprite.play("walk")
#		$Sprite.flip_h = true if velocity.x < 1 else false
#	elif Input.is_action_pressed("right"):
#		velocity.x = SPEED
#		$Sprite.play("walk")
#		$Sprite.flip_h = false
#	elif Input.is_action_pressed("left"):
#		velocity.x = -SPEED
#		$Sprite.flip_h = true
#		$Sprite.play("walk")
#	else:
#		$Sprite.play("idle")
#
#	if not is_on_floor():
#		$Sprite.play("air")

	velocity.y = velocity.y + GRAVITY * gravity_direction
	
	# Play jump sound
	#if Input.is_action_just_pressed("jump" + action_suffix) and is_on_floor():
	#	sound_jump.play()
	
	if is_on_floor():
		last_touched_ground = OS.get_system_time_msecs()

	var direction = get_direction()

	var is_jump_interrupted = Input.is_action_just_released("jump" + action_suffix) and velocity.y < 0.0
	velocity = calculate_move_velocity(velocity, direction, SPEED, is_jump_interrupted)

	var snap_vector = Vector2.ZERO
	if direction.y == 0.0:
		snap_vector = Vector2.DOWN * FLOOR_DETECT_DISTANCE
	var is_on_platform = platform_detector.is_colliding()
	velocity = move_and_slide_with_snap(
		velocity, snap_vector, FLOOR_NORMAL, not is_on_platform, 4, 0.9, false
	)

#	velocity = move_and_slide(velocity, Vector2.UP * gravity_direction)
#
#	velocity.x = lerp(velocity.x, 0, 0.1)

# This function calculates a new velocity whenever you need it.
# It allows you to interrupt jumps.
func calculate_move_velocity(
		linear_velocity,
		direction,
		speed,
		is_jump_interrupted
	):
	var velocity = linear_velocity
	velocity.x = speed.x * direction.x
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
		Input.get_action_strength("move_right" + action_suffix) - Input.get_action_strength("move_left" + action_suffix),
		-1 if on_floor_or_coyote and Input.is_action_just_pressed("jump" + action_suffix) else 0
	)


func reset_scene():
	get_tree().change_scene("res://Level1.tscn")


func jump():
	if is_on_floor():
		velocity.y = JUMP_FORCE * gravity_direction


func _on_Fallzone_body_entered(_body):
	reset_scene()


func bounce(bounciness):
	velocity.y += bounciness


func force_bounce(bounciness):
	velocity.y = bounciness


func side_force_bounce(bounciness):
	velocity.x = bounciness


func take_damage(enemyPosition: float):
	if not is_alive:
		return

	is_alive = false
	set_modulate(Color(1, 0.3, 0.3, 0.3))
	var direction = -1 if enemyPosition > position.x else 1
	velocity.y += JUMP_FORCE * 0.3
	velocity.x += 800 * direction
	$Timer.start()


func _on_Timer_timeout():
	reset_scene()
