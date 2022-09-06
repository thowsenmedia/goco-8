class_name Project extends Reference

var Map = load("res://Project/Map.gd")

var name:String
var path:String
var title:String
var version:int = 0
var tilesets := {}
var scripts := {}
var maps := {}
var meta := {}

var is_loaded:bool = false
var is_loaded_from_packed_file := false

func _init(project_name:String):
	name = project_name
	path = "user://projects/" + project_name


func has_meta(key:String) -> bool:
	return meta.has(key)


func get_meta(key:String, default = null):
	if has_meta(key):
		return meta[key]
	else:
		return default


func put_meta(key, value):
	meta[key] = value


func get_project_file() -> String:
	return path + "/" + name + ".project"

func get_code_dir() -> String:
	return path + "/code"

func get_tilesets_dir() -> String:
	return path + "/tilesets"

func get_music_dir() -> String:
	return path + "/music"

func get_sfx_dir() -> String:
	return path + "/sfx"

func load_data() -> bool:
	var f = File.new()
	var project_file = get_project_file()
	if f.file_exists(project_file):
		var err = f.open(project_file, File.READ)
		if err:
			ES.echo("Failed to open project file " + project_file + ". Err: " + str(err))
			return false
		else:
			var data = f.get_var(true)
			unserialize(data)
			f.close()
	is_loaded = true
	return true


func create_tileset(name:String, width: int, height: int, tilesize: int):
	var tileset = Tileset.new()
	var tileset_path = path + "/tilesets/" + name + ".png"
	tileset.create(tileset_path, name, width, height, tilesize)
	tilesets[name] = tileset
	return tileset


func create_map(name:String, width: int, height: int, tilesize: int):
	var map = Map.new(name, width, height, tilesize)
	maps[name] = map
	return map


func get_map(name:String) -> Map:
	return maps[name]


func save_data():
	var f = File.new()
	var project_file = get_project_file()
	var err = f.open(project_file, File.WRITE)
	if err:
		ES.echo("Failed to open project_file for saving. Err: " + str(err))
		return false
	
	version += 1
	
	save_tilesets()
	
	f.store_var(serialize(), true)
	f.close()
	ES.echo("Project data saved.")
	return true


func load_compiled_script(name:String):
	name = name.trim_prefix(get_code_dir())
	name = name.replace(".es", ".gd")
	var file = get_code_dir() + "/" + name
	
	var f = File.new()
	var err = f.open(file, File.READ)
	if err == OK:
		var script = GDScript.new()
		script.source_code = f.get_as_text()
		f.close()
		return script
	else:
		ES.echo("Failed to load compiled script at " + file + ". Err: " + str(err))


# get all .es scripts in /code project dir
func get_scripts() -> Array:
	var scripts = []
	
	var dir = Directory.new()
	var err = dir.open(get_code_dir())
	if err == OK:
		dir.list_dir_begin(true, true)
		
		var script_file:String = dir.get_next()
		while script_file != "":
			if dir.current_is_dir() == false:
				if script_file.ends_with(".gd"):
					scripts.append(script_file)
			script_file = dir.get_next()
		
		dir.list_dir_end()
	else:
		ES.echo("Failed to open code directory " + get_code_dir() + ". Err: " + str(err))
	
	return scripts


func get_compiled_scripts() -> Array:
	var compiled = []
	var scripts = get_scripts()
	for script_file in scripts:
		compiled.append(load_compiled_script(script_file))
	return compiled


func compile_scripts():
	var scripts = get_scripts()
	var f = File.new()
	for source_file in scripts:
		ES.escript.compile_file(get_code_dir() + "/" + source_file)
	
	return true


func save_tilesets():
	for tileset in tilesets.values():
		tileset.save_file()


func pack():
	var packed = {
		"name": name,
		"tilesets": {},
		"maps": {},
		"scripts": {},
		"meta": meta,
		"version": version,
		"title": title,
	}
	
	# tilesets
	for tileset in tilesets.values():
		packed["tilesets"][tileset.title] = tileset.pack()
	
	# scripts
	var scripts = get_scripts()
	for script in scripts:
		packed["scripts"][script] = ResourceLoader.load(get_code_dir() + "/" + script, "", false)
	
	return packed


func unpack(packed:Dictionary):
	name = packed.name
	meta = packed.meta
	version = packed.version
	title = packed.title
	tilesets = {}
	scripts = {}
	
	# tilesets
	for tileset_data in packed.tilesets.values():
		var tileset = Tileset.new()
		tileset.unpack(tileset_data)
		tilesets[tileset_data.title] = tileset
	
	# scripts
	var script_keys = packed.scripts.keys()
	var i = 0
	for script in packed.scripts.values():
		scripts[script_keys[i]] = script
		i += 1
	
	is_loaded = true
	is_loaded_from_packed_file = true


func serialize():
	var data = {
		"tilesets": {},
		"maps": {},
		"scripts": {},
		"meta": meta,
		"version": version
	}
	
	for tileset in tilesets.values():
		data["tilesets"][tileset.title] = tileset.serialize()
	
	for map in maps.values():
		data["maps"][map.name] = map.serialize()
	
	return data


func unserialize(data:Dictionary):
	if data.has("meta"):
		meta = data.meta
	
	# tilesets
	for tileset_data in data.tilesets.values():
		var tileset = Tileset.new()
		tileset.unserialize(tileset_data)
		tilesets[tileset.title] = tileset
	
	if data.has("version"):
		version = data.version
	
	if data.has("title"):
		title = data.title
	
	# maps
	if data.has("maps"):
		for map_data in data.maps.values():
			var map = Map.new()
			map.unserialize(map_data, self)
			maps[map.name] = map
