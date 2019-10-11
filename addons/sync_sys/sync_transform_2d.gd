extends "sync_node.gd"

export(bool) var interpolate = false
export(float) var lerp_speed = 10


func _enter_tree():
	if !node is Node2D:
		enabled = false
		return
	if is_network_master():
		data.transform = node.transform
	connect("spawned", self, "_spawned")


func _spawned(data):
	if !is_network_master():
		node.transform = data.transform


func _process(delta):
	if is_network_master():
		data.transform = node.transform
	else:
		if !data.has("transform"):
			return
		if interpolate:
			node.transform = node.transform.interpolate_with(data.transform, lerp_speed * delta)
		else:
			node.transform = data.transform
