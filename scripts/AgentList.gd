extends VBoxContainer
onready var agentTree = get_node("AgentListTree")

signal EditModeChanged
	
func LoadAgents(Agents):
	agentTree.clear()
	var root = agentTree.create_item()
	root.set_text(0,"ID")
	root.set_text(1,"Start Location")
	root.set_text(2,"Goal Location")
	for agent in Agents:
		var itm = agentTree.create_item(root)
		itm.set_text(0,agent.id)
		itm.set_editable(0,false)
		itm.set_text(1,String(agent.start))
		itm.set_editable(1,false)
		itm.set_text(2,String(agent.goal))
		itm.set_editable(2,false)

func RemoveAgent(Agent) -> void:
	var child = agentTree.get_root().get_children()
	while child != null:
		if child.get_text(1) == String(Agent.start): #TODO this should actually be the ID, not the start location
			child.free()
			agentTree.update()
			break
		else:
			child = child.get_next()
			
func AddAgent(Agent) -> void:
	var itm = agentTree.create_item(agentTree.get_root())
	itm.set_text(0,Agent.id)
	itm.set_editable(0,false)
	itm.set_text(1,String(Agent.start))
	itm.set_editable(1,false)
	itm.set_text(2,String(Agent.goal))
	itm.set_editable(2,false)

func _on_AgentListTree_item_double_clicked():
	agentTree.edit_selected()


func _on_AgentEditMode_toggled(button_pressed):
	emit_signal("EditModeChanged",button_pressed)
	var child = agentTree.get_root().get_children()
	while child != null:
		child.set_editable(1,button_pressed)
		child.set_editable(2,button_pressed)
		child = child.get_next()
