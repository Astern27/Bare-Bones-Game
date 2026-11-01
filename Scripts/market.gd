class_name Market
extends Node2D

static var money = 0
static var score = 0
static var multiply = 1
static var caught = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	money += Player.bones * multiply * caught
	money += Player.skulls * 10 * multiply * caught
	money += Player.teeth * 25 * multiply * caught
	score += Player.bones * multiply * caught
	score += Player.skulls * 10 * multiply * caught
	score += Player.teeth * 25 * multiply * caught
	money = int(round(money))
	$Money.text = "$" + str(money)
	Player.level += 1


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/main.tscn")
