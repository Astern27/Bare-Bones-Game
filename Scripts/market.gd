class_name Market
extends Node2D

static var money = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	money += Player.bones
	money += Player.skulls * 10
	money += Player.teeth * 50
	$Money.text = "$" + str(money)


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/main.tscn")
