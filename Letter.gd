extends Area2D

export(String) var letter setget set_letter

func set_letter(value):
	letter = value
	$Label.text = value

func _on_Letter_body_shape_entered(body_id, body, body_shape, local_shape):
	var playerLetter = body.letter.letter
	body.pickup_letter(letter)
	if playerLetter:
		self.letter = playerLetter
	else:
		queue_free()
