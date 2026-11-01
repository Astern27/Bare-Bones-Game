class_name Dig
extends Node2D

@onready var player = get_node("../../Player")
static var shovel = 1
static var silent = 1
static var lucky = false
static var total = 0

func _ready() -> void:
	$Sprite2D.visible = false;
	$ProgressBar.visible = false;
	randomize()

func _process(_delta: float) -> void:
	if (Input.is_action_pressed("Dig")):
		var bodies = $Area2D.get_overlapping_bodies()
		for body in bodies:
			if body == player and !$Sprite2D.visible and get_node("../../CanvasLayer/Stamina").value >= 1:
				$ProgressBar.visible = true
				$ProgressBar.value -= .5 * shovel
				get_node("../../CanvasLayer/Stamina").value -= 1
				player.get_node("Noise/CollisionShape2D").shape.radius = 1500 * silent
				if $ProgressBar.value == 0:
					$Sprite2D.visible = true
					$ProgressBar.visible = false
					var chance = randi() % 20
					if lucky:
						if chance <= 8:
							player.bones += (randi() % 4) + 3
						elif chance <= 15:
							player.skulls += (randi() % 2) + 1
						else:
							player.teeth += 1
					else:
						if chance <= 10:
							player.bones += (randi() % 4) + 3
						elif chance <= 16:
							player.skulls += (randi() % 2) + 1
						else:
							player.teeth += 1
					get_node("../../CanvasLayer/Label").text = "Bones: " + str(player.bones) + "  Skulls: " + str(player.skulls) + "  Gold Teeth: " + str(player.teeth)
					total += 1
