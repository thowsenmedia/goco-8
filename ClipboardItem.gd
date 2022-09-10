class_name ClipboardItem extends Reference

enum TYPE {
	IMAGE,
	TEXT
}

var type = TYPE.TEXT
var image_data : Image
var text_data : String

func _init(t:int, d):
	type = t
	match type:
		TYPE.IMAGE:
			image_data = d
		TYPE.TEXT:
			text_data = d

func get_data():
	match type:
		TYPE.IMAGE:
			return image_data
		TYPE.TEXT:
			return text_data
