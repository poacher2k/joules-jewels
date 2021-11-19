extends Area2D

var is_active = false

func _on_Portal_body_entered(body):
	if is_active:
		get_tree().change_scene("res://WordArrange.tscn")

func coin_cap_reached():
	is_active = true
	visible = true
