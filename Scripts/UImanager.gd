extends CanvasLayer
class_name UImanager

var totalScore : int = 0
var score : int = 0

@export_category("shop pice ballancing")
var dropsBought : int = 0
@export var dropPrice : int = 300
@export var dropPriceUpFrequency : int = 10
@export var dropPriceIncrease : int = 100
var refillsBought : int = 0
@export var refillPrice : int = 700
@export var refillPriceUpFrequency : int = 5
@export var refillPriceIncrease : int = 100 

@onready var scoreTextbox: RichTextLabel = $Control/MarginContainer/VBoxContainer/Panel/Score
@onready var dropsTextbox: RichTextLabel = $Control/MarginContainer/VBoxContainer/Panel2/Drops
@onready var totalScoreTextbox: RichTextLabel = $Control/MarginContainer/VBoxContainer/Panel3/TotalScore

@export_category("linked nodes")
@export var player: Player
@onready var drop_shop: Button = $Control2/MarginContainer/VBoxContainer/Panel/DropShop
@onready var refill_machine: Button = $Control2/MarginContainer/VBoxContainer/Panel2/RefillMachine
@export var spawner: Spawner

func _ready() -> void:
	drop_shop.connect("pressed", on_drop_shop)
	refill_machine.connect("pressed", on_refill_machine)

func addScore(toAdd : int):
	score += toAdd
	totalScore += toAdd
	
func updateBoard(newDrops : int):
	scoreTextbox.text = "Money: " + str(score)
	dropsTextbox.text = "Drops: " + str(newDrops)
	totalScoreTextbox.text = "Score: " + str(totalScore)
	drop_shop.text = "Buy another drop (" + str(dropPrice) +" points)"
	refill_machine.text = "Refill Machine (" + str(refillPrice) +" points)"

func on_drop_shop():
	drop_shop.release_focus()
	if score < dropPrice: return
	player.drops += 1
	score -= dropPrice
	dropsBought += 1
	if dropsBought != dropPriceUpFrequency : updateBoard(player.drops); return
	dropsBought = 0
	dropPrice += dropPriceIncrease
	updateBoard(player.drops)

func on_refill_machine():
	refill_machine.release_focus()
	if score < refillPrice or not player.currentState == player.STATE.IDLE: return
	spawner.refill()
	score -= refillPrice
	refillsBought += 1
	updateBoard(player.drops)
	
