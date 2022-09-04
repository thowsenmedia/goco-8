extends HBoxContainer

const TilesetButton = preload("res://Spriter/Tileset/TilesetButton.tscn")

signal tileset_selected(tileset)

onready var scrollLeftButton = $ScrollLeft
onready var scrollRightButton = $ScrollRight
onready var scrollContainer = $ScrollContainer
onready var buttonsList = $ScrollContainer/ButtonList
onready var addTilesetButton = $AddTilesetButton

var is_scrolling_left:bool = false
var is_scrolling_right:bool = false

var current_tileset:Tileset

func _ready():
	scrollLeftButton.connect("button_down", self, "_start_scroll_left")
	scrollLeftButton.connect("button_up", self, "_stop_scroll_left")
	scrollRightButton.connect("button_down", self, "_start_scroll_right")
	scrollRightButton.connect("button_up", self, "_stop_scroll_right")


func clear():
	current_tileset = null
	for button in buttonsList.get_children():
		buttonsList.remove_child(button)


func has_button_for(tileset:Tileset):
	for button in buttonsList.get_children():
		if button.tileset_title == tileset.title:
			return true
	return false


func add_tileset_button(tileset:Tileset):
	var button = TilesetButton.instance()
	button.tileset_title = tileset.title
	buttonsList.add_child(button)
	button.connect("pressed", self, "_select_tileset", [tileset])


func select_tileset(tileset:Tileset):
	if current_tileset:
		get_tileset_button(current_tileset.title).selected(false)
	
	current_tileset = tileset
	get_tileset_button(current_tileset.title).selected(true)
	

func get_tileset_button(title:String):
	for button in buttonsList.get_children():
		if button.tileset_title == title:
			return button
	
	return null


func _select_tileset(tileset:Tileset):
	if current_tileset:
		get_tileset_button(current_tileset.title).selected(false)
	
	get_tileset_button(tileset.title).selected(true)
	current_tileset = tileset
	emit_signal("tileset_selected", tileset)


func _start_scroll_left():
	is_scrolling_left = true

func _stop_scroll_left():
	is_scrolling_left = false

func _start_scroll_right():
	is_scrolling_right = true

func _stop_scroll_right():
	is_scrolling_right = false

func _process(delta):
	if is_scrolling_left:
		scrollContainer.scroll_horizontal -= 1
	elif is_scrolling_right:
		scrollContainer.scroll_horizontal += 1
