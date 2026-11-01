extends Node2D

static var v = true

func _ready() -> void:
	visible = v




func _on_button_pressed() -> void:
	if Market.money >= 125:
		Market.money -= 125
		Dig.lucky = true
		get_node("../Money").text = "$" + str(Market.money)
		visible = false
		v = false
