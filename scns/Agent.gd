extends Node2D

class Agent:
	var start: Vector2
	var goal: Vector2
	var PlannedPath:Array = []
	
	var _currentStep: int

func StepPos(speed : float, nodeWidth : int, nodeHeight : int, spacing : int) -> void:
	lerp()
