extends Area2D

export var next_level : PackedScene
export var souls_needed = -1.0
export var current_souls = 0.0
export var particles_per_soul = 50.0
export var max_radius = 100.0

var is_active = false

func finish_level():
	get_tree().change_scene_to(next_level)

func make_active():
	if is_active:
		return

	is_active = true

	$Sprite.play("open")

func _on_Exit_body_entered(body):
	if not is_active:
		return

	if not $FinishAudio.playing:
		$FinishAudio.play()
