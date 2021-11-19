extends TileMap

export (int) var remove_date_unix_time

export var debug = false


func _ready():
	check_removal()


func _physics_process(_delta):
	check_removal()


func check_removal():
	var now = OS.get_system_time_secs()

	if now >= remove_date_unix_time || debug:
		queue_free()
