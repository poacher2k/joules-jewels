extends Area2D

export(String) var letter
export(String) var message

var ProximityText = preload("res://ProximityText.tscn")

onready var initial_pos = global_position

func _ready():
	var is_picked_up = Global.collected_coins.has(name)
	if is_picked_up:
		$CollisionShape2D.set_deferred('disabled', true)
		transitionToEndState()

func _on_Coin_body_entered(body):
	$AnimationPlayer.play("bounce")
	$CollisionShape2D.set_deferred('disabled', true)
	get_tree().call_group("HUD", "on_Coin_collected", self)

func transitionToEndState():
	$AnimationPlayer.play("fade_and_slow")
	var proximityText = ProximityText.instance()
	proximityText.displayText = message
	proximityText.position = global_position
	get_tree().current_scene.call_deferred("add_child", proximityText)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "bounce":
		transitionToEndState()
