extends Area2D

export var souls_needed = -1.0
export var current_souls = 0.0
export var particles_per_soul = 50.0
export var max_radius = 100.0

export (NodePath) var exitPath
onready var exit = get_node(exitPath)

signal soul_collected

func _ready():
	Global.reset()

func collect_soul():
	$Sprite.play("grind")
	$Sprite.frame = 0

	current_souls += 1

	emit_signal("soul_collected", current_souls, souls_needed)

	if not $SoulCollectPlayer.playing:
		$SoulCollectPlayer.play()

	if current_souls >= souls_needed:
		$FinishAudio.play()

func finish_level():
	exit.make_active()

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



func _on_Sprite_animation_finished():
	$Sprite.play("idle")
