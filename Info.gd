extends Node

var version = "0.2.1"
const cell_size = 8

var render_distance = 8

var settings = {
	"echo_recordings": true,
	"restore_logs_to_memory": false,
	"record_navigation_details": false,
	"enable_test_set": true,
}
func _ready():
	var file = File.new()
	if (file.open("res://settings.json", File.READ)) == OK:
		settings = parse_json(file.get_as_text())
	else:
		LogRecorder.record("Unable to load res://info.json")
