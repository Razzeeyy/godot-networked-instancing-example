extends Control


func _on_Node2DButton_pressed():
	get_tree().change_scene("examples/node_2d/Main.tscn")


func _on_SpatialButton_pressed():
	get_tree().change_scene("examples/spatial/Main.tscn")


func _on_RigidBody2D_pressed():
	get_tree().change_scene("examples/rigid_body_2d/Main.tscn")


func _on_RigidBody3D_pressed():
	get_tree().change_scene("examples/rigid_body_3d/Main.tscn")


func _on_Cheating_pressed():
	get_tree().change_scene("examples/cheating/Main.tscn")
