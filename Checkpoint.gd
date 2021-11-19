extends Area2D

func _on_Checkpoint_body_entered(body):
	if not body.is_alive:
		return

	var is_current_checkpoint = Global.current_checkpoint == global_position

	$CPUParticles2D.emission_sphere_radius = 64
	Global.set_checkpoint(self)

	if not is_current_checkpoint:
		$AnimationPlayer.play("Fade-in-out")
