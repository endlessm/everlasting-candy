class_name ResourceFinder

# TODO: Fetch this list of recognised image format extensions from the engine.
# You might might hope that you could use
# ResourceLoader.get_recognized_extensions_for_type("Image") or
# ResourceLoader.get_recognized_extensions_for_type("Texture2D"),
# but you would be disappointed.
const _IMAGE_EXTENSIONS = [".png", ".jpg", ".jpeg", ".svg", ".webp"]


## Lists scenes in the given resource directory, accounting for the fact that,
## when exported, resource files are renamed, but must be loaded by their
## original name.
##
## Returns the original basename of each scene in the given directory.
##
## TODO: in Godot 4.4, use ResourceLoader.list_directory()
##  https://docs.godotengine.org/en/latest/classes/class_resourceloader.html#class-resourceloader-method-list-directory
static func list_scenes(path: String) -> Array[String]:
	var scenes: Array[String]
	var dir := DirAccess.open(path)

	dir.list_dir_begin()
	var file := dir.get_next()
	while file:
		if file.ends_with(".tscn.remap"):
			scenes.append(file.left(-len(".remap")))
		elif file.ends_with(".tscn"):
			scenes.append(file)
		file = dir.get_next()
	dir.list_dir_end()

	return scenes


## Lists images in the given resource directory, accounting for the fact that,
## when exported, resource files are renamed, but must be loaded by their
## original name.
##
## Returns the original basename of each image in the given directory, or empty
## list if the directory does not exist.
##
## TODO: in Godot 4.4, use ResourceLoader.list_directory()
##  https://docs.godotengine.org/en/latest/classes/class_resourceloader.html#class-resourceloader-method-list-directory
static func list_images(path: String) -> Array[String]:
	var images: Array[String]
	var dir := DirAccess.open(path)

	if not dir:
		var err := DirAccess.get_open_error()
		match err:
			# Weirdly trying to open a nonexistant resource path
			# yields ERR_INVALID_PARAMETER
			ERR_FILE_NOT_FOUND | ERR_INVALID_PARAMETER:
				pass
			_:
				print_debug("Can't list directory %s: %s" % [path, err])

		return images

	dir.list_dir_begin()
	var file := dir.get_next()
	while file:
		if _IMAGE_EXTENSIONS.any(func(ext): return file.ends_with(ext + ".import")):
			images.append(file.left(-len(".import")))
		file = dir.get_next()
	dir.list_dir_end()

	return images


## Loads all images in the given resource directory, if it exists.
static func load_images(path: String) -> Array[Texture2D]:
	var image_filenames := list_images(path)
	var textures: Array[Texture2D]
	for filename in image_filenames:
		var texture := load(path.path_join(filename)) as Texture2D
		textures.append(texture)
	return textures


## Loads images from the Image/$kind directory adjacent to the current scene (looked up via 'node'),
## if any such images exist.
static func load_world_assets(node: Node, kind: String) -> Array[Texture2D]:
	var tree := node.get_tree()
	var current_scene := tree.current_scene
	var world_path := current_scene.scene_file_path
	var path := world_path.get_base_dir().path_join("Image").path_join(kind)
	return ResourceFinder.load_images(path)
