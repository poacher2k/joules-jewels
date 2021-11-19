extends Area2D

onready var particles = $Particles

export(String) var letter

var is_filled = false

func set_letter(value):
	$Label.text = value

func _on_LetterBox_body_entered(body):
	if is_filled:
		return

	var playerLetter = body.letter.letter
	if playerLetter == letter:
		set_letter(playerLetter)
		is_filled = true
		particles.emitting = false
		body.pickup_letter("")

func letter_touched(touchedLetter):
	if is_filled:
		return

	particles.emitting = touchedLetter == letter
