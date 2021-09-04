class_name Agent
extends Node2D

var start: Vector2
var goal: Vector2
var PlannedPath:Array = []

var _currentStep : int = 0
var _currentSpeed : float
var _atPosition : bool = true

func _init() -> void:
	_currentStep = 0

func LoadPath(data : Dictionary) -> void:
	pass

func SavePath() -> String:
	var data : Dictionary = {}
	for i in range(PlannedPath.size()):
		var tmp : Dictionary = {}
		tmp["x"] = PlannedPath[i].x
		tmp["y"] = PlannedPath[i].y
		data[i] = tmp
	return JSON.print(data,'\t')
	
	
func Load(path : Array) -> void:
	PlannedPath = path
	start = path[0]
	position = Map.GetWorldFromGrid(start)
	$Sprite.visible = true

func StepPos(speed : float) -> void:
	_atPosition = false
	_currentSpeed = speed
	goal = PlannedPath[_currentStep + 1]
	
func _process(delta) -> void:
	if !_atPosition:
		var dir = goal - start
		position += dir * _currentSpeed * delta
		
		if position == Map.GetWorldFromGrid(goal):
			_atPosition = true
			_currentStep += 1
