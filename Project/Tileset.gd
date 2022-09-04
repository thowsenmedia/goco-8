class_name Tileset extends Reference

var path:String
var filename:String
var title:String
var tile_size:int

var saved:bool = false

var image:Image
var texture:ImageTexture

var tile_meta = {}

func create(path:String, title:String, width: int, height: int, tile_size:int = 8):
	self.path = path
	self.title = title
	self.tile_size = tile_size
	image = Image.new()
	image.create(width, height, false, Image.FORMAT_RGBA8)
	image.lock()
	texture = ImageTexture.new()
	texture.create_from_image(image, 0)
	saved = false


func get_region(index:int):
	var columns = int(image.get_size().x) / tile_size
	var x = index % columns
	var y = index / columns
	return Rect2(x * tile_size, y * tile_size, tile_size, tile_size)


func update_texture():
	saved = false
	texture.set_data(image)


func save_file():
	image.unlock()
	var err = image.save_png(path)
	image.lock()

	if err:
		ES.echo("Failed to save image to path " + path + ". Err:" + str(err))
		return false
	return true


func pack() -> Dictionary:
	var packed = {
		"title": title,
		"filename": filename,
		"tile_size": tile_size,
		"tile_meta": tile_meta,
		"image_data": image.get_data(),
		"image_width": image.get_width(),
		"image_height": image.get_height()
	}
	return packed


func unpack(packed: Dictionary):
	title = packed.title
	filename = packed.filename
	tile_size = packed.tile_size
	tile_meta = packed.tile_meta
	var img_data = packed.image_data
	image = Image.new()
	image.create_from_data(packed.image_width, packed.image_height, false, Image.FORMAT_RGBA8, packed.image_data)
	texture = ImageTexture.new()
	texture.create_from_image(image, 0)


func serialize() -> Dictionary:
	return {
		"path": path,
		"title": title,
		"filename": filename,
		"tile_size": tile_size,
		"tile_meta": tile_meta
	}


func unserialize(data:Dictionary):
	self.path = data.path
	filename = data.filename
	tile_size = data.tile_size
	tile_meta = data.tile_meta
	title = data.title

	load_file()


func load_file():
	var f = File.new()
	var err = f.open(path, File.READ)
	if err:
		ES.echo("Failed to open image at " + path + ". Err:" + str(err))
		return false

	var buffer = f.get_buffer(f.get_len())
	f.close()

	image = Image.new()
	image.load_png_from_buffer(buffer)

	texture = ImageTexture.new()
	texture.create_from_image(image, 0)


