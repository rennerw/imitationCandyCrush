extends CanvasLayer

var nextScenePath

func fade_to(path):
	nextScenePath = path
	get_node("Anim").play("Fade")
	
func change_scene():
	if nextScenePath != null:
		get_tree().change_scene(nextScenePath)