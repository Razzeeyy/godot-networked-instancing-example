extends "sync_node.gd"

export(bool) var interpolate = false
export(float) var lerp_speed = 10
export(float) var epsilon = 0.01

var dirty = false


func _enter_tree():
	if !node is RigidBody2D:
		enabled = false
		return
	if !is_connected("spawned", self, "_spawned"):
		connect("spawned", self, "_spawned")
	if !is_connected("replicated", self, "_replicated"):
		connect("replicated", self, "_replicated")


func _before_spawn():
	._before_spawn()
	data.transform = node.transform


func _spawned(data):
	node.transform = data.transform


func _replicated(data):
	if is_network_master():
		dirty = false
	else:
		dirty = true


func integrate_forces(state):
	if !enabled:
		return
	
	if is_network_master():
		data.transform = state.transform
		data.linear_velocity = state.linear_velocity
		data.angular_velocity = state.angular_velocity
		return
	
	if !dirty:
		return
	dirty = false
	
	if data.has("linear_velocity"):
		state.linear_velocity = data.linear_velocity
	if data.has("angular_velocity"):
		state.angular_velocity = data.angular_velocity
	
	if !data.has("transform"):
		return
	if interpolate:
		state.transform = state.transform.interpolate_with(data.transform, lerp_speed * state.step)
	else:
		state.transform = data.transform


func _physics_process(delta):
	if !enabled:
		return
	
	if !dirty || !node.sleeping:
		return
	
	var differs = false
	var squared_epsilon = epsilon * epsilon
	
	if data.has("linear_velocity"):
		if node.linear_velocity.distance_squared_to(data.linear_velocity) > squared_epsilon:
			differs = true
	elif data.has("angular_velocity"):
		if node.angular_velocity.distance_squared_to(data.angular_velocity) > squared_epsilon:
			differs = true
	elif data.has("transform"):
		if node.transform.origin.distance_squared_to(data.transform.origin) > squared_epsilon:
			differs = true
		elif node.transform.basis.is_equal_approx(data.transform.basis, squared_epsilon):
			differs = true
	
	if differs:
		node.sleeping = false