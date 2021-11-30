extends Node

func reset():
	var enemies = get_tree().get_nodes_in_group("enemies")
	var goal = get_tree().get_nodes_in_group("goals")[0]

	goal.souls_needed = enemies.size()
