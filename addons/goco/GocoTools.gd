tool extends Control

var PackedGame64Resource = load("res://PackedGame64Resource.gd")

onready var sourceFile = $VBoxContainer/HBoxContainer/SourceFile
onready var projectName = $VBoxContainer/HBoxContainer2/projectName

func _ready():
	$VBoxContainer/HBoxContainer2/SaveButton.connect("pressed", self, "_on_SaveButton_pressed")

func _on_SaveButton_pressed():
	print("Saving...")
	var source = sourceFile.text
	var project_name = projectName.text
	
	if source == "" or project_name == "":
		return
	
	
	var f = File.new()
	var err = f.open(source, File.read)
	if err:
		print("cannot open " + source + ". Err: " + str(err))
		return
	
	var packedGame = f.get_var(true)
	
	var packedGame64 = PackedGame64Resource.new()
	packedGame64.game_b64 = Marshalls.variant_to_base64(packedGame)
	
	print("Saving to res://demos/" + project_name + ".tres")
	
	err = ResourceSaver.save("res://demos/" + project_name + ".tres", packedGame64)
	if err:
		push_error("Failed to save .tres to demos folder: " + str(err))
