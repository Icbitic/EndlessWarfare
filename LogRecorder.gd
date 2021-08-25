extends Node2D

var rec = []
var show_recordings = true
func _ready():
	pass
func get_time_str():
	var time = OS.get_time()
	return ("[" + str(time.hour) + ":" + str(time.minute) 
			+ ":" + str(time.second) + "]")
#APIs
func record(massage):
	var text = get_time_str() + massage
	rec.append(text)
	if show_recordings:
		print(text)

func get_record():
	return rec
