class_name Agent
extends Node2D

var start: Vector2
var goal: Vector2
var PlannedPath:Array = []
var id:String = "1"

var _currentStep : int = 0
var _currentSpeed : float
var _atPosition : bool = true
var _destPosition : Vector2

func _init() -> void:
	_currentStep = 0

func LoadSaveData(agnt : Dictionary) -> void:
	var data : Dictionary = agnt["agent"]
	self.id = data["id"]
	self.start = Vector2(data["start"]["x"],data["start"]["y"])
	self.goal = Vector2(data["goal"]["x"],data["goal"]["y"])
	var path : Dictionary = data["path"]
	for i in range(path.size()):
		self.PlannedPath.append(Vector2(path[str(i)]["x"],path[str(i)]["y"]))
	
	position = Vector2(start.x * (32+2), start.y * (32 + 2))
	

func GetSaveData() -> String:
	var agnt  : Dictionary = {}
	var data : Dictionary = {}
	data["id"] = self.id
	data["start"] = {"x":self.start.x,"y":self.start.y}
	data["goal"] = {"x":self.goal.x,"y":self.goal.y}
	
	var path : Dictionary = {}
	for i in range(PlannedPath.size()):
		path[i] = {"x":self.PlannedPath[i].x,"y":self.PlannedPath[i].y}
	data["path"] = path
	agnt["agent"] = data
	return JSON.print(agnt,'\t')
	
	
func StepPos(speed : float) -> void:
	_atPosition = false
	_currentSpeed = speed
	_destPosition = PlannedPath[_currentStep + 1]
	
func _process(delta) -> void:
	if !_atPosition:
		var dir = _destPosition - PlannedPath[_currentStep]
		#position += dir * _currentSpeed * delta
		position.move_toward(_destPosition,delta * _currentSpeed)
		if position == get_parent().get_parent().currentMap.GetWorldFromGrid(_destPosition):
			_atPosition = true
			_currentStep += 1
