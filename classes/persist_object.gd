extends Node

class_name PersistObject

func setup():
	pass

func exit_loading():
	pass

func get_persist_data():
	var save_dict = {
		"filename": get_filename(),
		"parent" : get_parent().get_path()
	}
	return save_dict

func save():
	var persist_data = {}
	
	persist_data["ori"] = self.get_persist_data()
	
	for i in _get_all_children([]):
		if i.has_method("get_persist_data"):
			persist_data[i.get_path()] = i.get_persist_data()
			
	return persist_data

func _get_all_children(children: Array = [], node = self):
	for i in node.get_children():
		_get_all_children(children, i)
	if not node == self:
		children.append(node)
	return children
