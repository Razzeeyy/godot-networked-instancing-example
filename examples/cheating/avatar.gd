extends Node2D

export(float) var speed = 250

onready var _nickname = $Nickname
onready var _sync = $SyncTransform2D
onready var _sprite = $Sprite

var _cheating = false

func _ready():
	if multiplayer.is_network_server():
		_sync.validate = funcref(self, "_validate")
	#a random client has a chance to act as a cheater
	if !multiplayer.is_network_server() && is_network_master() && randf() > 0.5:
		_cheating = true
		_sprite.modulate = Color.red


func setup(spawn_position, nickname):
	position = spawn_position
	_nickname.text = nickname
	_sync.data.nickname = nickname


func _on_SyncNode_spawned(data):
	_nickname.text = _sync.data.nickname


func _validate(old_data, new_data):
	var allowed_distance = _sync.interval * speed
	var old_position = old_data.transform.origin
	var new_position = new_data.transform.origin
	var direction = new_position - old_position
	if  direction.length_squared() > allowed_distance * allowed_distance:
		new_position = old_position + direction.normalized() * allowed_distance
	new_data.transform.origin = new_position


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
	if Input.is_action_pressed("ui_right"):
		move.x += speed
	
	if _cheating:
		move *= Vector2.ONE * 3
	
	position += move * delta
