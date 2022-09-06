class_name Coder extends VBoxContainer

const Editor = preload("res://Coder/Editor.tscn")

export(bool) var testing:bool = false

var has_focus:bool = false

var project:Project

var code_template = """extends ESNode2D

func _start():
	pass

func _process(delta):
	pass

func _draw():
	pass
"""

func _ready():
	$Code/Sidebar/Tree.connect("request_open", self, "_on_request_open")
	if testing:
		var p = Project.new("blah")
		p.load_data()
		_open_project(p)
	

func _open_project(project:Project):
	self.project = project
	$Code/Sidebar/Tree.project = project
	$Code/Sidebar/Tree.set_folder(project.get_code_dir())
	
	if project.has_meta("editor_coder_tabs"):
		var files = project.get_meta("editor_coder_tabs")
		for file in files:
			open_file(file)
	
	$Code/Sidebar/FileMenu/AddScriptButton.disabled = false


func _close_project():
	$Code/Sidebar/Tree.clear()
	$Code/EditorTabs.clear()
	$Code/Sidebar/FileMenu/AddScriptButton.disabled = true
	$Code/Sidebar/Tree.project = null
	project = null


func _before_save_project(project:Project):
	var tabs = []
	for tab in $Code/EditorTabs.get_children():
		tabs.append(tab.file)
	
	if tabs.size() > 0:
		project.put_meta("editor_coder_tabs", tabs)


func _save_project(project:Project):
	for editor in $Code/EditorTabs.get_children():
		if editor.dirty:
			editor.save()


func grab_focus():
	has_focus = true
	$Code/EditorTabs.grab_focus()
	$Code/EditorTabs.grab_click_focus()


func release_focus():
	has_focus = false


func _input(event:InputEvent):
	if event.is_action("ctrl_tab") and event.pressed:
		if $Code/Sidebar.is_visible:
			$Code/Sidebar.hide()
			$Code/EditorTabs.grab_focus()
			$Code/EditorTabs.grab_click_focus()
		else:
			$Code/Sidebar.show()
			$Code/Sidebar.grab_focus()
			$Code/Sidebar.grab_click_focus()
		get_tree().set_input_as_handled()


func is_file_open(path:String):
	for editor in $Code/EditorTabs.get_children():
		if editor.file == path:
			return true
	return false


func _on_request_open(path:String):
	if not is_file_open(path):
		open_file(path)


func open_file(path:String):
	var f = File.new()
	
	var err = f.open(path, File.READ)
	if err:
		ES.echo("Editor failed to open file at " + path + ". Err:" + str(err))
		return false
		
	var text = f.get_as_text()
	f.close()
	
	var tab = Editor.instance()
	tab.file = path
	tab.text = text
	
	var tab_name = Array(path.split("/")).pop_back()
	
	$Code/EditorTabs.add_child(tab)
	$Code/EditorTabs.set_tab_title(tab.get_index(), tab_name)
	$Code/EditorTabs.current_tab = tab.get_index()
	$Code/EditorTabs.tabs_visible = true


func _on_AddScriptButton_pressed():
	var item:Node = $Code/Sidebar/Tree.new_file()
	item.connect("file_renamed", self, "_on_new_file_named", [item])


func _on_new_file_named(old_path, new_path, item):
	if not new_path.ends_with(".gd"):
		new_path = new_path + ".gd"
	
	var f = File.new()
	var err = f.open(new_path, File.WRITE)
	if err:
		ES.echo("Failed to open " + new_path + " for writing new code file. Err: " + str(err))
	else:
		f.store_line(code_template)
		f.close()
	
	item.disconnect("file_renamed", self, "_on_new_file_named")
	
	if not err:
		item.path = new_path
		open_file(new_path)
