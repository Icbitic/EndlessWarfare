extends Node2D

var pcks

func _ready():
	
	LogRecorder.record("Starting loading mods.")
	
	pcks = PckLoader.load_pck("mods")
	
	LogRecorder.record(str(pcks.size()) + " mod(s) loaded successfully.")
	
	for i in pcks:
		if is_compatible(i) == false:
			LogRecorder.record("Warning! " + i.name
					+ " is not compatible with this version")

func is_compatible(pck):
	if pck.has("version_support") == false:
		return ERR_DOES_NOT_EXIST
	return Info.info.version.match(pck.version_support)
