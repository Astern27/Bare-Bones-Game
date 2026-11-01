extends Node2D

func _ready() -> void:
	$Label2.text = "Total Money Made: $" + str(Market.score) + "\nTotal Gravestones Robbed: " + str(Dig.total)
