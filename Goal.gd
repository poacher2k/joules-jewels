extends Area2D

export var next_level : PackedScene
export var souls_needed = 10.0
export var current_souls = 0.0
export var particles_per_soul = 50.0
export var max_radius = 100.0

signal soul_collected

func _ready():
#	update_particles()
	print("HELLLOOOO")

func collect_soul():
	current_souls += 1
	update_particles()

	emit_signal("soul_collected")

	if current_souls >= souls_needed:
		get_tree().change_scene_to(next_level)

func update_particles():
	$Particles.emission_sphere_radius = (current_souls / souls_needed) * max_radius
	$Particles.amount = max(current_souls * particles_per_soul, 1)

	$Particles.emitting = current_souls > 0

func _on_Goal_area_entered(area):
	var parent = area.get_parent()
	if area.name == "PickupArea" and parent.is_in_group("enemies") and parent.is_flipped:
		var grandparent = parent.get_parent()
		if grandparent.name == "PickupHold":
			var joules = grandparent.get_parent()
			joules.current_pickup_type = null
			joules.current_pickup_instance = null

		parent.call_deferred("queue_free")
		collect_soul()

