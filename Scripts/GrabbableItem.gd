extends RigidBody2D
class_name GrabbableItem

const STROKE_MATERIAL = preload("uid://b4kqacs1icfy7")

@export var folder_path: String = "res://Items/"
@export var texture: Texture2D
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
var collider : CollisionShape2D
var canDelete : bool = false
enum RARITY {
	COMMON,
	UNCOMMON,
	RARE,
	LEGENDARY
}

var currentRarity : RARITY

func _ready():
	visible_on_screen_notifier_2d.screen_exited.connect(_screen_exited)
	currentRarity = _get_weighted_rarity()
	texture = _load_random_texture(folder_path + RARITY.find_key(currentRarity) + "/")
	var rect: Rect2 = Rect2(-0.5 * texture.get_size(), texture.get_size())
	visible_on_screen_notifier_2d.rect = rect
	
	_build_visual()
	_build_collision()

func _get_weighted_rarity() -> RARITY:
	var weights = {
		RARITY.COMMON: 60,
		RARITY.UNCOMMON: 25,
		RARITY.RARE: 10,
		RARITY.LEGENDARY: 5
	}

	var total_weight = 0
	for weight in weights.values():
		total_weight += weight

	var roll = randi_range(1, total_weight)

	var cumulative = 0
	for rarity in weights.keys():
		cumulative += weights[rarity]
		if roll <= cumulative:
			return rarity

	return RARITY.COMMON # fallback

func _screen_exited():
	if canDelete:
		queue_free()

func _load_random_texture(path: String) -> Texture2D:
	var dir := DirAccess.open(path)
	if dir == null:
		push_error("Cannot open folder: " + path)
		return null

	var textures: Array[String] = []

	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if !dir.current_is_dir():
			if file_name.ends_with(".png") or file_name.ends_with(".jpg") or file_name.ends_with(".webp"):
				textures.append(path + file_name)

		file_name = dir.get_next()

	dir.list_dir_end()

	if textures.is_empty():
		push_error("No textures found in: " + path)
		return null

	var chosen_path: String = textures.pick_random()
	return load(chosen_path)

func _build_visual():
	var sprite := Sprite2D.new()
	sprite.texture = texture
	if not currentRarity == RARITY.COMMON:
		sprite.material = STROKE_MATERIAL.duplicate()
		sprite.material.set_shader_parameter("stroke_size", 3.0)
		match currentRarity:
			RARITY.UNCOMMON:
				sprite.material.set_shader_parameter("stroke_color", Color.GREEN)
			RARITY.RARE:
				sprite.material.set_shader_parameter("stroke_color", Color.PURPLE)
			RARITY.LEGENDARY:
				sprite.material.set_shader_parameter("stroke_color", Color.GOLD)
	add_child(sprite)

func _build_collision():
	if texture == null:
		return

	var size := texture.get_size()

	var col := CollisionShape2D.new()
	var shape := CapsuleShape2D.new()

	var is_horizontal := size.x > size.y
	
	var thickness = min(size.x, size.y)
	var length = max(size.x, size.y)

	shape.radius = thickness/2
	
	shape.height = length
	
	if is_horizontal:
		col.rotation_degrees = 90

	col.shape = shape
	collider = col
	add_child(col)
