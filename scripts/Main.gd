
extends Node

export(PackedScene) var NodeTile
export(PackedScene) var ObstacleTile
export(PackedScene) var AgentScn

onready var agentTree = get_node("UI/CanvasLayer/VBoxContainer/AgentList/AgentListTree")

var SavedPath : Array = []
var currentMap : Map = Map.new()

var Agents: Array = []

var AgentEditMode : bool = false

class Map:
	var width : int
	var height : int
	var spacing : int
	var NodeSize = Vector2()
	
	var Obstacles : Array = []
	
	func Save():
		var data : Dictionary = {}
		data["width"] = self.width
		data["height"] = self.height
		data["nodeWidth"] = self.NodeSize.x
		data["nodeHeight"] = self.NodeSize.y
		data["spacing"] = self.spacing
		var obstacles : Dictionary = {}
		for i in range(self.Obstacles.size()):
			var tmp : Dictionary = {}
			tmp["x"] = self.Obstacles[i].x
			tmp["y"] = self.Obstacles[i].y
			obstacles[i] = tmp
		data["obstacles"] = obstacles
		return data
	
	func Load(data : Dictionary) -> void:
		self.width = data["width"]
		self.height = data["height"]
		self.NodeSize.x = data["nodeWidth"]
		self.NodeSize.y = data["nodeHeight"]
		self.spacing = data["spacing"]
		var obs = data["obstacles"]
		for i in range(obs.size()):
			self.Obstacles.append(Vector2(obs[str(i)]["x"],obs[str(i)]["y"]))

	func GetWorldFromGrid(gridPos : Vector2) -> Vector2:
		return Vector2(gridPos.x * (self.NodeSize.x + self.spacing) + self.NodeSize.x / 2, gridPos.y * (self.NodeSize.y + self.spacing) + self.NodeSize.y / 2)
	
	func GetGridFromWorld(worldPos : Vector2) -> Vector2:
		return Vector2((worldPos.x - self.NodeSize.x / 2) / (self.NodeSize.x + self.spacing), (worldPos.y -self.NodeSize.y / 2) / (self.NodeSize.y + self.spacing))
		

	

func saveMap():
	currentMap.width = currentMap.width
	currentMap.height = currentMap.height
	currentMap.NodeSize = Vector2(32,32)
	currentMap.spacing = 2
	var fi = File.new()
	fi.open("res://maps/" + $UI/CanvasLayer/VBoxContainer/HBoxContainer/VBoxContainer2/Map/MapFile.text + ".json", File.WRITE)
	fi.store_string(JSON.print(currentMap.Save(),"\t"))
	fi.close()

func drawMap():
	
	var fi = File.new()
	fi.open("res://maps/" + $UI/CanvasLayer/VBoxContainer/HBoxContainer/VBoxContainer2/Map/MapFile.text + ".json", File.READ)
	var text = fi.get_as_text()
	var result_json = JSON.parse(text)
	currentMap.Load(result_json.result)
	fi.close()
	
	for i in range(currentMap.width):
		for j in range(currentMap.height):
			var ti
			ti = NodeTile.instance()
			ti.gridLocation = Vector2(i,j)
			if currentMap.Obstacles.find(Vector2(i,j)) >= 0:
				ti.pressed = true
				ti.obstacle = true
			else:
				ti.pressed = false
				ti.obstacle = false
			$map.add_child(ti)
			ti.SetPosition(currentMap.GetWorldFromGrid(Vector2(i,j)))
			ti.connect("TypeToggled", self, "_on_Node_Toggled")
			

func savePath():
	var fi = File.new()
	fi.open("res://" + $UI/CanvasLayer/VBoxContainer/HBoxContainer/VBoxContainer2/Steps/StepFile.text + ".json", File.WRITE)
	fi.store_string(AgentScn.GetSaveData())
	fi.close()

func loadPath() -> void:
	var fi = File.new()
	fi.open("res://" + $UI/CanvasLayer/VBoxContainer/HBoxContainer/VBoxContainer2/Steps/StepFile.text + ".json", File.READ)
	var text = fi.get_as_text()
	var result_json = JSON.parse(text)
	fi.close()
	
func _on_Button_pressed():
	drawMap()


func _on_Save_pressed():
	saveMap()

func SearchAgents(gridLocation: Vector2) -> int:
	var result = -1
	for agnt in Agents:
		if agnt.start == gridLocation:
			result = Agents.find(agnt)
			break
	return result

func _on_Node_Toggled(pressed: bool, gridLocation: Vector2)-> void:
	if not AgentEditMode:
		if pressed:
			currentMap.Obstacles.erase(gridLocation)
		else:
			currentMap.Obstacles.append(gridLocation)
	else:
		#If it's been pressed, it's already an agent, so go ahead and remove it
		var idx = SearchAgents(gridLocation)
		if idx > -1:
			agentTree.get_parent().RemoveAgent(Agents[idx])
			Agents[idx].queue_free()
			Agents.remove(idx)	
		else:
			var agnt = AgentScn.instance()
			agnt.Create(gridLocation)
			$map.add_child(agnt)
			Agents.append(agnt)
			agentTree.get_parent().AddAgent(agnt)

func _on_SaveSteps_pressed():
	AgentScn.PlannedPath.append(Vector2(1,0))
	AgentScn.PlannedPath.append(Vector2(2,0))
	AgentScn.PlannedPath.append(Vector2(2,1))
	AgentScn.PlannedPath.append(Vector2(2,2))
	AgentScn.PlannedPath.append(Vector2(3,2))
	AgentScn.PlannedPath.append(Vector2(4,2))
	savePath()


func _on_LoadSteps_pressed():
	
	var fi = File.new()
	fi.open("res://maps/" + $UI/CanvasLayer/VBoxContainer/HBoxContainer/VBoxContainer2/Steps/StepFile.text + ".txt", File.READ)
	var index = 1
	while not fi.eof_reached():
		var line = fi.get_line() as String
		var paths = line.substr(line.find(": ") + 2,line.length()).split("->",false)
		if paths.size() > 0:
			var agnt = AgentScn.instance()
			agnt.ParsePathString(paths)
			$map.add_child(agnt)
			Agents.append(agnt)
	fi.close()
	
	agentTree.get_parent().LoadAgents(Agents)
	

func _on_Move_pressed():
	for agnt in Agents:
		agnt.StepPos(50)
	

func _on_BtnExport_pressed():
	# Export the current map to a txt file for EECBS running
	ExportMap($UI/CanvasLayer/VBoxContainer/HBoxContainer/VBoxContainer2/Map/MapFile.text + ".txt")
	pass # Replace with function body.

func ExportMap(filePath : String) -> void:
	var fi = File.new()
	fi.open("res://maps/" + filePath,File.WRITE)
	fi.store_string("type octile\n")
	fi.store_string("height " + String(currentMap.height) + "\n")
	fi.store_string("width " + String(currentMap.width) + "\n")
	for y in range(0,currentMap.height,1):
		var line = "" as String
		for x in range(0,currentMap.width,1):
			if currentMap.Obstacles.find(Vector2(x,y)) >= 0:
				line += "@"
			else:
				line += "."
		line += "\n"
		fi.store_string(line)
	fi.close()


func _on_AgentList_EditModeChanged(ButtonPressed):
	AgentEditMode = ButtonPressed
