extends Node2D
var info = {
	"version": "0.0.1"
}
var pcks

signal mod_loaded

func _ready():
	LogRecorder.record("Starting loading mods.")
	pcks = PckLoader.load_pck("mods")
	LogRecorder.record(str(pcks.size()) + " mod(s) loaded successfully.")
	for i in pcks:
		if is_compatible(i) == false:
			LogRecorder.record("Warning! " + i.name
					+ " is not compatible with this version")
	emit_signal("mod_loaded")

func is_compatible(pck):
	return Info.info.version.match(pck.version_support)
