extends Node2D

var rec = []

signal log_recorded

func get_time_str(time):
	var t = [str(time.hour), str(time.minute), str(time.second)]
	for i in t.size():
		if t[i].length() == 1:
			t[i] = "0" + t[i]
	return ("[" + t[0] + ":" + t[1] + ":" + t[2] + "]")

# APIs
func record(massage, level = 0):
	var content = {
		"time": OS.get_time(),
		"text": massage,
		"level": level
	}
	
	rec.append(content)
	if Info.settings.echo_recordings:
		print(get_time_str(content.time) + content.text)
		
	emit_signal("log_recorded")

func get_record():
	return rec
