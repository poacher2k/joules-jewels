extends Node

export var delete_save = false

func _ready():
	if delete_save:
		print("Deleting save")
		var dir = Directory.new()
		dir.remove("user://savegame.save")
	else:
		load_game()

var collected_letters = ""
var collected_coins = []

func collect_coin(coin):
	if collected_coins.has(coin.name):
		return

	collected_coins.append(coin.name)
	collected_letters += coin.letter

var current_checkpoint = null

func set_checkpoint(checkpoint):
	if checkpoint.global_position != current_checkpoint:
		current_checkpoint = checkpoint.global_position
		save_game()

func save_game():
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)

	var node_data = {
		"collected_letters": collected_letters,
		"collected_coins": collected_coins,
		"current_checkpoint": var2str(current_checkpoint)
	}

	# Store the save dictionary as a new line in the save file.
	save_game.store_line(to_json(node_data))
	save_game.close()

# Note: This can be called from anywhere inside the tree. This function
# is path independent.
func load_game():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		print("No save file exist")
		return # Error! We don't have a save to load.

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	save_game.open("user://savegame.save", File.READ)
	while save_game.get_position() < save_game.get_len():
		# Get the saved dictionary from the next line in the save file
		var node_data = parse_json(save_game.get_line())

		# Now we set the remaining variables.
		for i in node_data.keys():
			var current_data = node_data[i]
			if i == "current_checkpoint":
				self.set(i, str2var(current_data))
			else:
				self.set(i, current_data)

	save_game.close()

	get_tree().reload_current_scene()
