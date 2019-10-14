extends RigidBody2D

export(float) var speed = 250

onready var _nickname = $Nickname
onready var _sync = $SyncRigidBody2D


func setup(spawn_position, nickname):
	position = spawn_position
	_nickname.text = nickname
	_sync.data.nickname = nickname


func _on_SyncNode_spawned(data):
	_nickname.text = _sync.data.nickname


func _integrate_forces(state):
	_sync.integrate_forces(state)


func _physics_process(delta):
	if !is_network_master():
		return
	
	var move = Vector2.ZERO
	
	if Input.is_action_pressed("ui_up"):
		move.y -= speed
	if Input.is_action_pressed("ui_down"):
		move.y += speed
	if Input.is_action_pressed("ui_left"):
		move.x -= speed
		angular_velocity -= 5 * delta
	if Input.is_action_pressed("ui_right"):
		move.x += speed
		angular_velocity += 5 * delta
	
	linear_velocity += move * delta
