extends Node

export var delete_save = false

func _ready():
	var enemies = get_tree().get_nodes_in_group("enemies")
	var goal = get_tree().get_nodes_in_group("goals")[0]

	goal.souls_needed = enemies.size()
	goal.update_particles()

var collected_letters = ""
var collected_coins = []

func collect_coin(coin):
	if collected_coins.has(coin.name):
		return

	collected_coins.append(coin.name)
	collected_letters += coin.letter
