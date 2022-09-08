class_name Coder extends VBoxContainer

const Editor = preload("res://Coder/Editor.tscn")

export(bool) var testing:bool = false
export(String) var testing_project_name := "rpg"

var has_focus:bool = false

var project:Project

var code_template = """extends ESNode2D

func _start():
	pass

func _tick(delta):
	pass

func _draw():
	pass
"""

func _ready():
	$Code/Sidebar/Tree.connect("request_open", self, "_on_request_open")
	$Code/Sidebar/Tree.connect("item_renamed", self, "_on_tree_item_renamed")
	$Code/Sidebar/Tree.connect("item_autoload_changed", self, "_on_item_autoload_changed")
	
	if testing:
		var p = Project.new(testing_project_name)
		p.load_data()
		_open_project(p)
		grab_focus()
		has_focus = true
	

func _open_project(project:Project):
	self.project = project
	$Code/Sidebar/Tree.project = project
	$Code/Sidebar/Tree.set_folder(project.get_code_dir())
	
	if project.has_meta("editor_coder_tabs"):
		var files = project.get_meta("editor_coder_tabs")
		for file in files:
			if not is_file_open(file):
				open_file(file)
	
	if project.has_meta("editor_coder_current_tab_id"):
		var tabID = project.get_meta("editor_coder_current_tab_id")
		$Code/EditorTabs.current_tab = tabID
	
	if project.has_meta("editor_coder_current_line"):
		var line = project.get_meta("editor_coder_current_line")
		var editor:TextEdit = $Code/EditorTabs.get_current_tab_control()
		editor.cursor_set_line(line)
	
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
		if not tabs.has(tab.file):
			tabs.append(tab.file)
	
	if tabs.size() > 0:
		project.put_meta("editor_coder_tabs", tabs)
		var tabID = $Code/EditorTabs.current_tab
		var tab:TextEdit = $Code/EditorTabs.get_tab_control(tabID)
		project.put_meta("editor_coder_current_tab_id", tabID)
		
		# save current line as well
		var line = tab.cursor_get_line()
		project.put_meta("editor_coder_current_line", line)

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
	if not has_focus:
		return
	
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


func _on_request_open(item, path:String):
	if not is_file_open(path):
		open_file(path)
	
	var editor = $Code/EditorTabs.get_current_tab_control()
	if editor.file != path:
		$Code/EditorTabs.current_tab = get_editor_tab_from_file(path).get_index()


func get_editor_tab_from_file(path:String) -> Node:
	var tab_name = Array(path.split("/")).pop_back().trim_suffix('.gd')
	for editor in $Code/EditorTabs.get_children():
		if editor.file == path:
			return editor
	return null


func open_file(path:String):
	print("Opening " + path)
	var f = File.new()
	
	var err = f.open(path, File.READ)
	if err:
		ES.echo("Editor failed to open file at " + path + ". Err:" + str(err))
		return false
		
	var text = f.get_as_text()
	f.close()
	
	var tab_title = Array(path.split("/")).pop_back().trim_suffix('.gd')
	var tab = Editor.instance()
	tab.file = path
	tab.text = text
	
	$Code/EditorTabs.add_child(tab)
	$Code/EditorTabs.set_tab_title(tab.get_index(), tab_title)
	$Code/EditorTabs.current_tab = tab.get_index()
	$Code/EditorTabs.tabs_visible = true


func _on_tree_item_renamed(item, file_name:String, new_file_name:String):
	var err = $Code/Sidebar/Tree.directory.rename(file_name, new_file_name)
	if err:
		print("failed to renamed " + file_name + " TO " + new_file_name + ". Err: " + str(err))
		item.path = file_name
		return
	
	var tab = get_editor_tab_from_file(file_name)
	tab.file = new_file_name
	var tab_title = Array(new_file_name.split("/")).pop_back().trim_suffix('.gd')
	$Code/EditorTabs.set_tab_title(tab.get_index(), tab_title)
	
	print("renamed " + file_name + " > " + new_file_name)


func _on_AddScriptButton_pressed():
	var item:Node = $Code/Sidebar/Tree.add_file("")
	item.connect("file_renamed", self, "_on_new_file_named", [item])
	item.start_edit()


func _on_new_file_named(old_path, new_path, item):
	if old_path == "" and new_path == "":
		disconnect("file_renamed", self, "_on_new_file_named")
		print("cancelled new file creation")
		return
	
	old_path = $Code/Sidebar/Tree.directory.get_current_dir() + "/" + old_path
	new_path = $Code/Sidebar/Tree.directory.get_current_dir() + "/" + new_path

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
	item.get_node("Autoload").show()
	if not err:
		open_file(new_path)


func _on_RemoveScriptButton_pressed():
	if $Code/Sidebar/Tree.focused_item:
		var item = $Code/Sidebar/Tree.focused_item
		
		item.queue_free()


func _on_item_autoload_changed(item, file:String, autoload:bool):
	file = file.trim_prefix(project.get_code_dir()).trim_prefix("/")
	
	if not project.has_meta("autoload"):
		project.put_meta("autoload", [])
	
	var al:Array = project.get_meta("autoload")
	
	if autoload and not al.has(file):
			al.append(file)
	elif al.has(file):
		al.remove(al.find(file))
	
	project.put_meta("autoload", al)
