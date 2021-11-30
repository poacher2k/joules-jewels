extends CanvasLayer

func update_souls_text(souls, total):
	$Counter/Coins.text = String(souls) + " / " + String(total)

func _on_Goal_soul_collected(souls, total):
	update_souls_text(souls, total)

