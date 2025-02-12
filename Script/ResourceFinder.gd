class_name ResourceFinder

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
