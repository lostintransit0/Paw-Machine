extends Node
class_name Spawner

const GRABBABLE_ITEM = preload("uid://cnph5f86ucn03")
@export var spawnCount : int = 20
@export var uiManager : UImanager

func _ready() -> void:
	spawnLot()

func refill():
	removeOld()
	spawnLot()


func spawnLot():
	var newitem: GrabbableItem
	for i in spawnCount - 1:
		newitem = GRABBABLE_ITEM.instantiate()
		add_child(newitem)

func removeOld():
	var children := get_children()
	for child in children:
		child.collider.disabled = true
		child.z_index = -1000
		child.modulate = Color.WEB_GRAY
		child.canDelete = true

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
