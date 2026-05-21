extends CanvasLayer
class_name UImanager

var score : int = 0
@onready var scoreTextbox: RichTextLabel = $Control/VBoxContainer/Panel/Score
@onready var dropsTextbox: RichTextLabel = $Control/VBoxContainer/Panel2/Drops

func addScore(toAdd : int):
	score += toAdd
	print(score)
	
func updateBoard(newDrops : int):
	scoreTextbox.text = "Score: " + str(score)
	dropsTextbox.text = "Drops: " + str(newDrops)
