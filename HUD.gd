extends CanvasLayer

func update_souls_text(souls, total):
	$Counter/Coins.text = String(souls) + " / " + String(total)

func _on_Goal_soul_collected(souls, total):
	update_souls_text(souls, total)



func _on_Control_mouse_entered():
	var window = JavaScript.get_interface("window")
	if window:
		window.focus()


func _on_Control_focus_exited():
	var window = JavaScript.get_interface("window")
	if window:
		window.focus()
