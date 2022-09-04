class_name Token extends Reference

var type:int
var value

func _init(t: int, v = null):
	type = t
	value = v

func _to_string():
	return value
