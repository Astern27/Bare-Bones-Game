extends Node2D





func _on_button_pressed() -> void:
	if Market.money >= 25:
		Market.money -= 25
		Player.max_stamina += 50
		get_node("../Money").text = "$" + str(Market.money)
