class_name ResourceFinder

# TODO: Fetch this list of recognised image format extensions from the engine.
# You might might hope that you could use
# ResourceLoader.get_recognized_extensions_for_type("Image") or
# ResourceLoader.get_recognized_extensions_for_type("Texture2D"),
# but you would be disappointed.
const _IMAGE_EXTENSIONS = [".png", ".jpg", ".jpeg", ".svg", ".webp"]


## Lists images in the given resource directory, recursively.
##
## Returns the absolute path of each image, or an empty list if the directory
## does not exist.
static func list_images(path: String) -> Array[String]:
	var images: Array[String]

	for file in ResourceLoader.list_directory(path):
		if file.ends_with("/"):
			images.append_array(list_images(path.path_join(file)))
		elif _IMAGE_EXTENSIONS.any(func(ext): return file.ends_with(ext)):
			images.append(path.path_join(file))

	return images


## Loads all images in the given resource directory, if it exists.
static func load_images(path: String) -> Array[Texture2D]:
	var image_filenames := list_images(path)
	var textures: Array[Texture2D]
	for filename in image_filenames:
		var texture := load(filename) as Texture2D
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
