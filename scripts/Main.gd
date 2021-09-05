
extends Node

export(PackedScene) var NodeTile
export(PackedScene) var ObstacleTile
export(PackedScene) var AgentScn

var SavedPath : Array = []
var currentMap : Map = Map.new()
var Agent1

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
		return Vector2(gridPos.x * (self.NodeSize.x + self.spacing), gridPos.y * (self.NodeSize.y + self.spacing))
	
	func GetGridFromWorld(worldPos : Vector2) -> Vector2:
		return Vector2(worldPos.x / (self.NodeSize.x + self.spacing), worldPos.y / (self.NodeSize.y + self.spacing))
		
		
func _init():
	pass
		

func saveMap():
	currentMap.width = 4
	currentMap.height = 4
	currentMap.NodeSize = Vector2(32,32)
	currentMap.spacing = 2
	currentMap.Obstacles.append(Vector2(0,0))
	currentMap.Obstacles.append(Vector2(0,1))
	var fi = File.new()
	fi.open("res://tst.json", File.WRITE)
	fi.store_string(JSON.print(currentMap.Save(),"\t"))
	fi.close()

func drawMap():
	
	var fi = File.new()
	fi.open("res://tst.json", File.READ)
	var text = fi.get_as_text()
	var result_json = JSON.parse(text)
	currentMap.Load(result_json.result)
	fi.close()
	
	for i in range(currentMap.width):
		for j in range(currentMap.height):
			var ti
			if currentMap.Obstacles.find(Vector2(i,j)) >= 0:
				ti = ObstacleTile.instance()
			else:
				ti = NodeTile.instance()
			$map.add_child(ti)
			ti.position = currentMap.GetWorldFromGrid(Vector2(i,j))
			

func savePath():
	var fi = File.new()
	fi.open("res://" + $UI/CanvasLayer/VBoxContainer/HBoxContainer/StepFile.text + ".json", File.WRITE)
	fi.store_string(AgentScn.GetSaveData())
	fi.close()

func loadPath() -> void:
	var fi = File.new()
	fi.open("res://" + $UI/CanvasLayer/VBoxContainer/HBoxContainer/StepFile.text + ".json", File.READ)
	var text = fi.get_as_text()
	var result_json = JSON.parse(text)
	fi.close()
	
func _on_Button_pressed():
	drawMap()


func _on_Save_pressed():
	saveMap()


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
	fi.open("res://" + $UI/CanvasLayer/VBoxContainer/HBoxContainer/StepFile.text + ".json", File.READ)
	var text = fi.get_as_text()
	var result_json = JSON.parse(text)
	Agent1 = AgentScn.instance()
	Agent1.LoadSaveData(result_json.result)
	$map.add_child(Agent1)
	fi.close()


func _on_Move_pressed():
	Agent1.StepPos(50)
