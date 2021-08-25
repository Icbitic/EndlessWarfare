extends Node2D

var rec = []
var show_recordings = true
func _ready():
	pass
	
func get_time_str():
	var time = OS.get_time()
	var t = [str(time.hour), str(time.minute), str(time.second)]
	for i in t.size():
		if t[i].length() == 1:
			t[i] = "0" + t[i]
	return ("[" + t[0] + ":" + t[1] + ":" + t[2] + "]")
#APIs
func record(massage):
	var text = get_time_str() + massage
	rec.append(text)
	if show_recordings:
		print(text)

func get_record():
	return rec
