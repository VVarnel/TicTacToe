extends CanvasLayer

signal restart
signal visibility

func _on_restart_button_pressed() -> void:
	restart.emit()


func _on_visibility_changed() -> void:
	if visible:
		visibility.emit()
