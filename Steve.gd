extends KinematicBody2D

export var SPEED = 200
const GRAVITY = 35
const JUMP_FORCE = -1100

export (NodePath) var joystickPath
onready var joystick: Joystick = get_node(joystickPath)

export (NodePath) var jumpBtnPath
onready var jumpBtn: JumpBtnJoystick = get_node(jumpBtnPath)

onready var letter = $Letter

var velocity = Vector2(0, 0)
var gravity_direction = 1
var is_alive = true


func _ready():
	jumpBtn.connect("touch_started", self, "jump")

	if Global.current_checkpoint != null:
		global_position = Global.current_checkpoint


func _physics_process(_delta):
	if joystick and joystick.is_working:
		velocity.x = joystick.output.x * SPEED
		$Sprite.play("walk")
		$Sprite.flip_h = true if velocity.x < 1 else false
	elif Input.is_action_pressed("right"):
		velocity.x = SPEED
		$Sprite.play("walk")
		$Sprite.flip_h = false
	elif Input.is_action_pressed("left"):
		velocity.x = -SPEED
		$Sprite.flip_h = true
		$Sprite.play("walk")
	else:
		$Sprite.play("idle")

	if not is_on_floor():
		$Sprite.play("air")

	velocity.y = velocity.y + GRAVITY * gravity_direction

	if Input.is_action_just_pressed("jump"):
		jump()

	velocity = move_and_slide(velocity, Vector2.UP * gravity_direction)

	velocity.x = lerp(velocity.x, 0, 0.1)


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


func pickup_letter(touchedLetter):
	letter.letter = touchedLetter
	get_tree().call_group("LetterBoxes", "letter_touched", touchedLetter)


func _on_AntiGravStart_body_entered(body):
	gravity_direction = -1
	$Sprite.flip_v = true


func _on_AntiGravEnd_body_entered(body):
	gravity_direction = 1
	$Sprite.flip_v = false
