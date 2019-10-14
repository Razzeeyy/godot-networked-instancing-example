extends Control


func _on_Node2DButton_pressed():
	get_tree().change_scene("examples/node_2d/Main.tscn")


func _on_SpatialButton_pressed():
	get_tree().change_scene("examples/spatial/Main.tscn")
