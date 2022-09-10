tool class_name RainbowTextEffect extends RichTextEffect

export(Color) var start_color = Color.aqua
export(Color) var end_color = Color.palegreen

var bbcode := "rainbow"

func _process_custom_fx(char_fx : CharFXTransform) -> bool:
	var index = float(char_fx.absolute_index)
	
	var time = char_fx.elapsed_time + index
	
	char_fx.color = lerp(start_color, end_color, sin(time))
	
	return true
