extends CanvasLayer
class_name UImanager

var score : int = 0
@onready var scoreTextbox: RichTextLabel = $Control/VBoxContainer/Panel/Score
@onready var dropsTextbox: RichTextLabel = $Control/VBoxContainer/Panel2/Drops

@export var player: Player
@onready var drop_shop: Button = $Control2/VBoxContainer/Panel/DropShop
@onready var refill_machine: Button = $Control2/VBoxContainer/Panel2/RefillMachine
@export var spawner: Spawner

func _ready() -> void:
	drop_shop.connect("pressed", on_drop_shop)
	refill_machine.connect("pressed", on_refill_machine)

func addScore(toAdd : int):
	score += toAdd
	
func updateBoard(newDrops : int):
	scoreTextbox.text = "Score: " + str(score)
	dropsTextbox.text = "Drops: " + str(newDrops)

func on_drop_shop():
	drop_shop.release_focus()
	if score < 300: return
	player.drops += 1
	score -= 300
	updateBoard(player.drops)

func on_refill_machine():
	refill_machine.release_focus()
	if score < 700 or not player.currentState == player.STATE.IDLE: return
	spawner.refill()
	score -= 700
	updateBoard(player.drops)
	
