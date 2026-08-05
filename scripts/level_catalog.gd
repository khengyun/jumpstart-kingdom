extends RefCounted
class_name LevelCatalog

const DEFAULT_LEVEL_DIRECTORY: String = "res://scenes/levels"
const LEVEL_PREFIX: String = "level_"


static func discover(directory_path: String = DEFAULT_LEVEL_DIRECTORY) -> Array[PackedScene]:
	var level_files: Array[String] = []
	for entry: String in ResourceLoader.list_directory(directory_path):
		if entry.ends_with("/"):
			continue
		if not entry.begins_with(LEVEL_PREFIX):
			continue
		if entry.get_extension().to_lower() != "tscn":
			continue
		level_files.append(entry)

	level_files.sort_custom(_natural_file_order)
	var scenes: Array[PackedScene] = []
	for file_name: String in level_files:
		var resource_path: String = directory_path.path_join(file_name)
		var scene := ResourceLoader.load(resource_path, "PackedScene") as PackedScene
		if scene == null:
			push_error("Could not load discovered level scene: %s" % resource_path)
			continue
		if not _has_valid_level_contract(scene, resource_path):
			continue
		scenes.append(scene)
	return scenes


static func _natural_file_order(left: String, right: String) -> bool:
	return left.naturalnocasecmp_to(right) < 0


static func _has_valid_level_contract(scene: PackedScene, resource_path: String) -> bool:
	var candidate: Node = scene.instantiate()
	var missing_paths := PackedStringArray()
	if not (candidate is GameLevel):
		push_error("Discovered level root must use scripts/level.gd: %s" % resource_path)
		candidate.free()
		return false

	for required_path: String in [
		"Terrain", "Pickups", "Enemies", "GameplayAreas", "Markers/PlayerSpawn"
	]:
		if not candidate.has_node(required_path):
			missing_paths.append(required_path)
	candidate.free()
	if not missing_paths.is_empty():
		push_error(
			"Discovered level is missing required nodes (%s): %s"
			% [", ".join(missing_paths), resource_path]
		)
		return false
	return true
