extends Node2D

var player

func _ready() -> void:
	get_node("Sprite2D").visible = false;
	randomize()
	player = get_node("../../Player")

func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("Dig")):
		var bodies = get_node("Area2D").get_overlapping_bodies()
		for body in bodies:
			if body == player and !get_node("Sprite2D").visible:
				get_node("Sprite2D").visible = true;
				var chance = randi() % 10
				if chance <= 4:
					player.bones += (randi() % 4) + 3
				elif chance <= 7:
					player.skulls += (randi() % 2) + 1
				else:
					player.teeth += 1
				get_node("../../CanvasLayer/Label").text = "Bones: " + str(player.bones) + "  Skulls: " + str(player.skulls) + "  Teeth: " + str(player.teeth)
