extends Node2D

static var multi = 1

func _ready() -> void:
	$Button.text = "$" + str(round(25 * multi))

func _on_button_pressed() -> void:
	if Market.money >= round(25 * multi):
		Market.money -= round(25 * multi)
		Player.recharge *= 1.2
		get_node("../Money").text = "$" + str(Market.money)
		multi *= 1.3
		$Button.text = "$" + str(round(25 * multi))
