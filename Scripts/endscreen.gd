extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var rich_text_label: RichTextLabel = $Control/RichTextLabel

func _ready() -> void:
	animation_player.play("curtainRise")
	rich_text_label.text = "Final Score: " + str(Globals.FinalScore)
