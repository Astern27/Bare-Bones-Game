extends Node2D

static var v = true

func _ready() -> void:
	visible = v

func _on_button_pressed() -> void:
	if Market.money >= 50:
		Market.money -= 50
		Dig.shovel *= 1.3
		get_node("../Money").text = "$" + str(Market.money)
		visible = false
		v = false
