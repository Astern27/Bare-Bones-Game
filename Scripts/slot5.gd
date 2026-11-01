extends Node2D

static var v = true

func _ready() -> void:
	visible = v

func _on_button_pressed() -> void:
	if Market.money >= 75:
		Market.money -= 75
		Player.boots *= 0.7
		get_node("../Money").text = "$" + str(Market.money)
		visible = false
		v = false
