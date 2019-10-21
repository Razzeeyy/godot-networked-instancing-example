extends Control

const AvatarScene = preload("Avatar.tscn")
const Avatar = preload("avatar.gd")

onready var sync_root = $"/root/SyncRoot"
onready var validation_button = $VBoxContainer/ValidationButton


func _ready():
	validation_button.visible = false


func _on_ServerButton_pressed():
	sync_root.clear()
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(7331)
	get_tree().multiplayer.network_peer = peer
	multiplayer.connect("network_peer_connected", self, "_peer_connected")
	multiplayer.connect("network_peer_disconnected", self, "_peer_disconnected")
	$Status.text = "Server"
	spawn_avatar()
	validation_button.visible = true
	validation_button.pressed = true


func _on_ClientButton_pressed():
	sync_root.clear()
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client("localhost", 7331)
	get_tree().multiplayer.network_peer = peer
	multiplayer.connect("connected_to_server", self, "_connected")
	multiplayer.connect("server_disconnected", self, "_server_disconnected")
	$Status.text = "Client"
	validation_button.visible = false


func _on_DisconnectButton_pressed():
	sync_root.clear()
	get_tree().multiplayer.network_peer.close_connection()
	$Status.text = ""
	validation_button.visible = false


func _on_ValidationButton_toggled(button_pressed):
	if multiplayer.is_network_server():
		for child in sync_root.get_children():
			if child is Avatar:
				child.validate = button_pressed


func _peer_connected(id):
	sync_root.sync_client(id)


func _peer_disconnected(id):
	var avatar = sync_root.get_node_or_null(str(id))
	if avatar:
		sync_root.remove_child(avatar)


func _connected():
	rpc("spawn_avatar")


func _server_disconnected():
	sync_root.clear()
	$Status.text = ""


master func spawn_avatar():
	var id = multiplayer.get_rpc_sender_id()
	
	var host_call = multiplayer.is_network_server() && id == 0
	if host_call:
		id = 1
	
	var avatar = AvatarScene.instance()
	sync_root.add_child(avatar)
	avatar.name = str(id)
	avatar.set_network_master(id)
	avatar.setup(Vector2(randi()%500, randi()%500), avatar.name)
