extends Node

var matrix = []
var candyPre = preload("res://scenes/Candy.tscn")
var boxPre = preload("res://scenes/Box.tscn")

var lvl = 6

var obj1 = null
var obj2 = null

signal played

func _ready():
	clear_matrix()
	read_level()
	rand_matrix()
	
func read_level():
	var file = File.new()
	file.open("res://LevelData/Level"+str(lvl) + ".txt",file.READ)
	var text = file.get_as_text()
	var lines = text.split("\n")
	file.close()
	for x in range(9):
		for y in range(12):
			if lines[y][x] == "1":
				matrix[x][y] = gen_box(x,y)
	
func clear_matrix():
	for x in range(9):
		matrix.append([])
		matrix[x] = []
		for y in range(12):
			matrix[x].append([])
			matrix[x][y] = null
			

func rand_matrix():
	for x in range(9):
		for y in range(12):
			if matrix[x][y] == null:
				matrix[x][y] = gen_candy(x,y)
				
func gen_candy(x, y):
	var newCandy = candyPre.instance()
	
	newCandy.set_data(x, y)
	newCandy.connect("selected", self, "obj_sel")
	
	add_child(newCandy)
	newCandy.add_to_group("candy")
	return newCandy
	
func gen_box(x,y):
	var newBox = boxPre.instance()
	newBox.set_data(x,y)
	add_child(newBox)
	newBox.add_to_group("box")
	return newBox
	
func is_candy(obj):
	if obj != null and obj.is_in_group("candy"):
		return true
	else:
		return false
func obj_sel(obj,b):
	if b:
		if obj1 == null:
			obj1 = obj
		else:
			obj2 = obj
			if (test_prox()):
				emit_signal("played")
				obj1.move_to(obj2.x, obj2.y)
				obj2.move_to(obj1.x, obj1.y)
				matrix[obj1.x][obj1.y] = obj2
				matrix[obj2.x][obj2.y] = obj1
				
				get_node("Timer").start()
			else:
				obj1.desel()
				obj2.desel()
				obj1 = null
				obj2 = null

func test_prox():
	if obj1.x == obj2.x and abs(obj1.y - obj2.y) == 1 or obj1.y == obj2.y and abs(obj1.x - obj2.x) == 1:
		return true
	else:
		return false
		

func _on_Timer_timeout():
	if (find_pattern()):
		pass
	else:
		obj1.move_to(obj2.x, obj2.y)
		obj2.move_to(obj1.x, obj1.y)
		matrix[obj1.x][obj1.y] = obj2
		matrix[obj2.x][obj2.y] = obj1
	
	obj1.desel()
	obj2.desel()
	obj1 = null
	obj2 = null

func find_pattern():
	var to_remove = []
	var valid = false
	for y in range(12):
		for x in range(1, 8):
			var c0 = matrix[x-1][y].color if is_candy(matrix[x-1][y]) else null#print("c0")
			var c1 = matrix[x][y].color if is_candy(matrix[x][y]) else null#print("c1")
			var c2 = matrix[x+1][y].color if is_candy(matrix[x+1][y]) else null #print("c2")
			#print(str(c0)+","+str(c1)+","+str(c2))
			if c0 == c1 and c1 == c2 and c0 != null:
				add_to_remove(to_remove, matrix[x-1][y])
				add_to_remove(to_remove, matrix[x][y])
				add_to_remove(to_remove, matrix[x+1][y])
				valid = true

	for x in range(9):
		for y in range(1, 11):
			var c0 = matrix[x][y-1].color if is_candy(matrix[x][y-1]) else null
			var c1 = matrix[x][y].color if is_candy(matrix[x][y]) else null
			var c2 = matrix[x][y+1].color if is_candy(matrix[x][y+1]) else null
			
			if c0 == c1 and c1 == c2 and c0 != null:
				add_to_remove(to_remove, matrix[x][y-1])
				add_to_remove(to_remove, matrix[x][y])
				add_to_remove(to_remove, matrix[x][y+1])
				valid = true
					
	for t in to_remove:
		remove_child(t)
		matrix[t.x][t.y] = null
	
	move_down()
	get_node("Inter").start()
	return valid

func move_down():
	for y in range(11, -1, -1):
		var x = 0
		while (x <= 8):
			if y == 0:
				if matrix[x][y] == null:
					matrix[x][y] = gen_candy(x,y)
			if is_candy(matrix[x][y]):
				var moved = false
				var toy
				for i in range(y + 1,12):
					if matrix[x][i] == null:
						toy = i 
						moved = true 
					elif matrix[x][i].is_in_group("box"):
						continue
					else:
						break
				if moved:
					matrix[x][y].move_to(x,toy)
					matrix[x][toy] = matrix[x][y]
					matrix[x][y] = null
			if y == 0 and matrix[x][y] == null:
				pass
			else:
				x += 1
func add_to_remove(list,obj):
	if not list.has(obj):
		list.append(obj)

func _on_Inter_timeout():
	if not find_pattern():
		get_node("Inter").stop()
