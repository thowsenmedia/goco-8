class_name CodeEditor extends TextEdit

onready var suggestionsMenu:PopupMenu = $SuggestionsMenu

var file:String = ""
var dirty:bool = true

const COLORS = {
	"String": Color("99e550"),
	"Keyword": Color("fbf236"),
	"Constant": Color("d95763"),
	"Comment": Color("847e87")
}

const KEYWORDS = [
	'var', 'pass', 'self', 'func','return','void','break','continue',
	'class','class_name','extends',
	'if','elif','else','for','while','yield','enum', 'match'
]

const CONSTANTS = [
	"ESnode2D",
]

const SYMBOLS = {
	"frect": [],
	"brect": [],
	"script": [],
	"btn": [],
	"btn_a": [],
	"btn_b": [],
	"echo": [],
	"get_camrea": [],
	"camera": [],
	"get_map": [],
	"get_tileset": [],
	"draw_map": [],
	"draw_sprite": [],
	"line": [],
	"cls": [],
}

func _ready():
	# strings
	add_color_region("\"", "\"", COLORS.String)
	
	# comments
	add_color_region("#", "\n", COLORS.Comment, true)
	
	for kw in KEYWORDS:
		add_keyword_color(kw, COLORS.Keyword)
	
	for constant in CONSTANTS:
		add_keyword_color(constant, COLORS.Constant)
	
	connect("text_changed", self, "_on_text_changed")
	connect("cursor_changed", self, "_on_cursor_changed")


func _on_cursor_changed():
	begin_autocomplete()


func _on_text_changed():
	dirty = true
	begin_autocomplete()

func symbol_exists(symbol:String) -> bool:
	var names = SYMBOLS.keys()
	return names.has(symbol)


func get_currently_typing_word() -> Dictionary:
	var line = cursor_get_line()
	var col = cursor_get_column()
	
	if col == 0:
		return {}
	
	var code = get_line(line)
	if code.length() == 0:
		return {}
	
	# first, check if the previous character is a character
	var left = code.substr(col-1, 1)
	
	if left == " " or left == "\t":
		return {}
	
	var word_start = col
	var word_end = col
	
	var start_found = false
	var search_col = col - 1
	while not start_found:
		var character = code.substr(search_col, 1)
		if search_col == 0 or character == " " or character == "\t":
			start_found = true
			word_start = search_col + 1
		
		search_col -= 1
	
	var end_found = false
	search_col = col
	while not end_found:
		var character = code.substr(search_col, 1)
		if search_col == code.length() or character == " " or character == "\t":
			end_found = true
			word_end = search_col
		
		search_col += 1
	
	var word_length = abs(word_start - word_end)
	
	var word = code.substr(word_start, word_length)
	
	return {
		"start": word_start,
		"end": word_end,
		"word": word
	}


func replace_currently_typing_word(replacement:String):
	var line = cursor_get_line()
	var code = get_line(line)
	var current = get_currently_typing_word()
	
	if current.has("word"):
		print("replacing " + current.word + " with " + replacement)
		code = code.replace(current.word, replacement)
		set_line(line, code)


func begin_autocomplete():
	var line = cursor_get_line()
	var col = cursor_get_column()
	var word = get_word_under_cursor()
	if word.length() == 0:
		var current = get_currently_typing_word()
		
		if not current.has("word") or current.word.length() == 0:
			suggestionsMenu.hide()
			return
		else:
			word = current.word
	
	print("word:" + word)
	
	if not symbol_exists(word):
		suggestionsMenu.clear()
			
		# let's find a match
		var matches = []
		var symbol_info
		for symbol_word in SYMBOLS.keys():
			symbol_info = SYMBOLS[symbol_word]
			
			if symbol_word.begins_with(word):
					matches.append({"word": symbol_word, "info": symbol_info})
	
		if matches.size() > 0:
			print(str(matches.size()) + " matches.")
			for m in matches:
				suggestionsMenu.add_item(m.word)
		
			show_suggestions()
	else:
		suggestionsMenu.hide()


func accept_suggestion():
	if suggestionsMenu.get_item_count() == 0:
		suggestionsMenu.hide()
		return
	
	var suggestion
	if suggestionsMenu.get_item_count() == 1:
		suggestion = suggestionsMenu.get_item_text(0)
	else:
		var selected = suggestionsMenu.get_current_index()
		if selected == -1:
			suggestionsMenu.hide()
			return
		
		suggestion = suggestionsMenu.get_item_text(selected)
	
	replace_currently_typing_word(suggestion)
	
	var word = get_currently_typing_word()
	cursor_set_column(word.start + word.word.length())
	
	suggestionsMenu.hide()


func get_string_size(string:String) -> Vector2:
	var font = get_theme_default_font()
	var tabs = string.count("\t")
	var tab_width = font.get_char_size(KEY_SPACE).x * 4
	var size = font.get_string_size(string)
	size.x += tab_width * tabs
	return size


func show_suggestions():
	var line = cursor_get_line()
	var col = cursor_get_column()
	var code = get_line(line).substr(0, col)
	
	print(code)
	
	print("lline = " + str(line))
	print("col = " + str(col))
	var font = get_theme_default_font()
	var font_height = get_line_height()
	var x = get_string_size(code).x
	
	var rect_pos = get_global_rect().position
	
	print("editor pos: " + str(rect_pos))
	
	var pos = Vector2(x, font_height * (line + 1))
	var menu:PopupMenu = suggestionsMenu
	menu.rect_position = rect_pos + pos
	suggestionsMenu.popup()


func save():
	var f = File.new()
	var err = f.open(file, File.WRITE)
	if err == OK:
		f.store_string(text)
		f.close()
		dirty = false
		ES.echo("Saved " + file)
	else:
		ES.echo("Failed to save " + file + ". Err: " + str(err))
