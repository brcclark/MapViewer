extends Button

signal TypeToggled(value,location)

class_name NodeTile

var obstacle = false
var gridLocation = Vector2.ZERO

func SetPosition(_pos : Vector2) -> void:
	self.rect_position = _pos + Vector2(-32,-32)

func _on_NodeTile_toggled(button_pressed):
	obstacle = not button_pressed
	emit_signal("TypeToggled",obstacle,gridLocation)
