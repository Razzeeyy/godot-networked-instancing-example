extends Node2D

export(float) var speed = 250

const LERP_SPEED = 10

onready var _nickname = $Nickname
onready var _sync = $SyncNode


func setup(spawn_position, nickname):
	position = spawn_position
	_sync.data.position = spawn_position
	_nickname.text = nickname
	_sync.data.nickname = nickname


func _on_SyncNode_spawned(data):
	_nickname.text = _sync.data.nickname
	position = _sync.data.position


func _physics_process(delta):
	if !is_network_master():
		var lerp_weight = LERP_SPEED*delta
		position.x = lerp(position.x, _sync.data.position.x, lerp_weight)
		position.y = lerp(position.y, _sync.data.position.y, lerp_weight)
		return
	
	var move = Vector2.ZERO
	
	if Input.is_action_pressed("ui_up"):
		move.y -= speed
	if Input.is_action_pressed("ui_down"):
		move.y += speed
	if Input.is_action_pressed("ui_left"):
		move.x -= speed
	if Input.is_action_pressed("ui_right"):
		move.x += speed
	
	position += move * delta
	_sync.data.position = position
