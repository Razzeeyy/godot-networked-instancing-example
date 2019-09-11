extends Control

const AvatarScene = preload("res://Avatar.tscn")

onready var sync_root = $"/root/SyncRoot"


func _on_ServerButton_pressed():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(7331)
	get_tree().multiplayer.network_peer = peer
	multiplayer.connect("network_peer_connected", self, "_peer_connected")
	multiplayer.connect("network_peer_disconnected", self, "_peer_disconnected")
	$Status.text = "Server"


func _on_ClientButton_pressed():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client("localhost", 7331)
	get_tree().multiplayer.network_peer = peer
	multiplayer.connect("connected_to_server", self, "_connected")
	$Status.text = "Client"


func _on_DisconnectButton_pressed():
	get_tree().multiplayer.network_peer.close_connection()
	$Status.text = ""
	for child in sync_root.get_children():
		child.queue_free()


func _peer_connected(id):
	sync_root.sync_client(id)


func _peer_disconnected(id):
	var avatar = sync_root.get_node_or_null(str(id))
	if avatar:
		sync_root.remove_child(avatar)


func _connected():
	rpc("spawn_avatar")


master func spawn_avatar():
	var id = multiplayer.get_rpc_sender_id()
	var avatar = AvatarScene.instance()
	sync_root.add_child(avatar)
	avatar.name = str(id)
	avatar.set_network_master(id)
	avatar.set_nickname(avatar.name)
	avatar.spawn_at(Vector2(randi()%500, randi()%500))
