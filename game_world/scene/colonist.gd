extends Node


enum TASK_TYPE {CONSTRUCT}
enum RESOURCE_TYPE {STEEL, WOOD, STONE}

const TASK_TYPE_AMOUNT = 2

var task_set: TaskSet

var task_picker: TaskPicker

var resources: Dictionary setget , _get_resources

####               ####
#                     #
#    INNER ClASSES    #
#                     #
####               ####

# Strategy Pattern
class TaskPickStrategy:
	func get_task():
		pass
	
class PickLocallyNearestTask:
	extends TaskPickStrategy
	
	
	func _init():
		pass
	
	func pick_task(tasks: Array, resources, colonist_pos: Vector2):
		if tasks.size() == 0:
			return ERR_DOES_NOT_EXIST
			
		match _get_task_type(tasks[0]):
			TASK_TYPE.CONSTRUCT:
				var res_result: ResourceObject
				var res_min_dis = -1
				for i in resources:
					var dis = colonist_pos.distance_to(resources[i].position)
					if res_min_dis == -1:
						res_min_dis = dis
						res_result = i
					elif dis < res_min_dis:
						res_min_dis = dis
						res_result = i
				
				if res_min_dis == -1:
					return ERR_DOES_NOT_EXIST
				
				var tar_result: Task
				var tar_min_dis = -1
				for i in tasks:
					if i.resource_type != res_result.type:
						continue
					var dis = colonist_pos.distance_to(tasks[i].construct_position)
					
					if tar_min_dis == -1:
						tar_min_dis = dis
						tar_result = i
					elif dis < tar_min_dis:
						tar_min_dis = dis
						tar_result = i
				
				if res_min_dis == -1 or tar_min_dis == -1:
					return ERR_DOES_NOT_EXIST
						
				return TaskSchedule.new(res_result, tar_result)
		
	func _get_task_type(task):
		if task is ConstructTask:
			return TASK_TYPE.CONSTRUCT
		return ERR_DOES_NOT_EXIST
		
class TaskPicker:
	var task_pick_strategy
	
	func _init(strategy):
		task_pick_strategy = strategy
	
	func pick_task(tasks, resources, colonist_pos):
		var res = task_pick_strategy.pick_task(tasks, resources, colonist_pos)
		return res

class TaskSchedule:
	var resource_position: Vector2
	var target_position: Vector2
	
	var resource
	var target
	
	func _init(res, tar):
		resource = res
		resource_position = res.pos
		
		target = tar
		target_position = tar.pos

class TaskSet:
	
	var tasks = []
	
	func _init():
		tasks.resize(TASK_TYPE_AMOUNT)
		for i in TASK_TYPE_AMOUNT:
			var arr = []
			tasks[i] = arr
	
	func add_task(task):
		if task is ConstructTask:
			tasks[TASK_TYPE.CONSTRUCT].append(task)
			return OK
		
	func get_tasks_by_type(task_type):
		return tasks[task_type]
	
class Task:
	func _to_string():
		var string = "Task type: Task"
		
		return string
	
class ConstructTask:
	extends Task
	var resource_type
	var construct_position
	var cell_id
	
	func _init(pos, res_type, id):
		construct_position = pos
		resource_type = res_type
		cell_id = id
		
	func _to_string():
		var string = "Task type: ConstructTask\n"\
		+ "resource_type: " + str(resource_type) + "\n"\
		+ "construct_position: " + str(construct_position) + "\n"\
		+ "cell_id: " + str(cell_id) + "\n"
		
		return string
		
func _ready():
	task_picker = TaskPicker.new(PickLocallyNearestTask.new())
	task_set = TaskSet.new()
	_add_commands()

func add_task(task):
	var err = task_set.add_task(task)
	return err

func get_task(task_type, colonist_pos = null):
	# Use closest task strategy as default.
	var task = task_picker.pick_task(task_set.get_tasks_by_type(task_type), resources, colonist_pos)
	
	return task
	
####               ####
#                     #
#   PRIVATE METHODS   #
#                     #
####               ####

func _get_resources():
	resources = get_parent().get_resources_on_map()
	return resources
		

func _add_commands():
	Console.add_command("addconstructtask", self, "_add_construct_task_cmd")\
	.add_argument("target_position_x", TYPE_INT)\
	.add_argument("target_position_y", TYPE_INT)\
	.add_argument("resource_type", TYPE_INT)\
	.add_argument("cell_id", TYPE_INT)\
	.set_description("Add a construct task.")\
	.register()
	
	Console.add_command("gettask", self, "_get_task_cmd")\
	.add_argument("task_type", TYPE_INT)\
	.add_argument("colonist_position_x", TYPE_INT)\
	.add_argument("colonist_position_y", TYPE_INT)\
	.set_description("Get a task.")\
	.register()
	
	Console.add_command("listtasks", self, "_list_tasks_cmd")\
	.add_argument("task_type", TYPE_INT)\
	.set_description("List all tasks.")\
	.register()

func _add_construct_task_cmd(target_position_x, target_position_y, resource_type, cell_id):
	var task = ConstructTask.new(Vector2(target_position_x, target_position_y),
			resource_type, cell_id)
	
	var err = add_task(task)
	return err

func _get_task_cmd(task_type, colonist_position_x, colonist_position_y):
	var task = get_task(task_type, Vector2(colonist_position_x, colonist_position_y))
	if typeof(task) == TYPE_INT:
		Console.write_line("Error code: " + str(task))
		return OK
	Console.write(task._to_string())
	return OK
	
func _list_tasks_cmd(task_type):
	var tasks = task_set.get_tasks_by_type(task_type)
	for i in range(tasks.size()):
		Console.write_line("#" + str(i))
		Console.write(tasks[i]._to_string())
	return OK
