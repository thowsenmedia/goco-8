class_name CoderTree extends VBoxContainer

signal request_open(file)

const CoderTreeItemScene = preload("res://Coder/CoderTreeItem.tscn")

var is_visible:bool = false

var directory:Directory = Directory.new()

var focused_item = null

var project:Project

func _ready():
	var err = directory.open("user://")
	if err == OK:
		set_folder(".")
	else:
		ES.error("Failed to open user://, error: " + str(err))


func set_project(p:Project):
	self.project = p


func get_current_dir() -> String:
	return directory.get_current_dir()


func set_folder(path:String):
	clear()
	
	var err = directory.change_dir(path)
	if err != OK:
		ES.echo("Failed to open " + path + ". Error: " + str(err))
		return
	directory.list_dir_begin(true, true)
	var file = directory.get_next()
	while file != "":
		if directory.current_is_dir():
			add_dir(file)
		else:
			if file.ends_with(".gd"):
				add_file(file)
		file = directory.get_next()
	directory.list_dir_end()
	
	if project:
		var cur_dir = directory.get_current_dir()
		var code_dir = project.get_code_dir()
		
		if cur_dir != code_dir:
			var backItem = add_dir(code_dir)
			backItem.text = "../"
			move_child(backItem, 1)


func clear():
	for child in get_children():
		if child is CoderTreeItem:
			remove_child(child)
			child.queue_free()
	focused_item = null


func create_item(type, path) -> CoderTreeItem:
	var item = CoderTreeItemScene.instance()
	item.type = type
	item.path = path
	item.connect("selected", self, "_on_select_item", [item])
	
	add_child(item)
	return item
	
func add_dir(file:String) -> CoderTreeItem:
	return create_item(CoderTreeItem.TYPE.DIRECTORY, file)

func add_file(file:String) -> CoderTreeItem:
	return create_item(CoderTreeItem.TYPE.FILE, file)

func new_file():
	var item = create_item(CoderTreeItem.TYPE.FILE, "")
	item.path = project.get_code_dir() + "/new.gd"
	item.start_edit()
	return item

func _on_select_item(item:CoderTreeItem):
	if item.type == CoderTreeItem.TYPE.DIRECTORY:
		set_folder(item.path)
	else:
		var file = directory.get_current_dir() + "/" + item.path
		emit_signal("request_open", file)

func grab_focus():
	if get_child_count() > 1:
		if is_instance_valid(focused_item) and focused_item:
			focused_item.grab_focus()
		else:
			get_child(1).grab_focus()

func toggle():
	if is_visible:
		hide()
	else:
		show()
