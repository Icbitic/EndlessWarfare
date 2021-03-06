extends Node

signal log_recorded

var rec = []

# Public Methods
func record(massage, level = 0):
	var content = {
		"time": OS.get_time(),
		"text": massage,
		"level": level
	}
	
	if Settings.restore_logs_to_memory:
		rec.append(content)
	if Settings.echo_recordings:
		print(get_time_str(content.time) + content.text)
		
	emit_signal("log_recorded")

func get_record():
	return rec

# Private Methods
func get_time_str(time):
	var t = [str(time.hour), str(time.minute), str(time.second)]
	for i in t.size():
		if t[i].length() == 1:
			t[i] = "0" + t[i]
	if Settings.logs_in_milliseconds:
		return ("[" + str(OS.get_ticks_msec()) + "ms]")
	else:
		return ("[" + t[0] + ":" + t[1] + ":" + t[2] + "]")
