extends Control

var hearts = 4 setget set_hearts
var max_hearts = 4 setget set_max_hearts

onready var heartUIEmpty = $HeartUIEmpty
onready var heartUIFull = $HeartUIFull

onready var heartSize = heartUIFull.texture.get_size().x

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	heartUIFull.rect_size.x = hearts * heartSize

func set_max_hearts(value):
	max_hearts = max(value, 1)
	self.hearts = min(hearts, max_hearts)
	heartUIEmpty.rect_size.x = max_hearts * heartSize

func _ready():
	self.hearts = 3
	self.max_hearts = 3


func _on_Joules_health_updated(health):
	set_hearts(health)
