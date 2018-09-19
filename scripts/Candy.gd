extends Area2D

var x
var y
var color

var destx
var desty
var posx
var posy

var special = false
var sel = false

signal selected(obj, b)

func _ready():
	randomize()
	
	color = int(rand_range(0,6))
	
	if rand_range(0,1) > 0.98:
		special = true
	
	if special:
		self.get_node("Sprite").set_animation("shine"+get_color(color))
	else:
		self.get_node("Sprite").set_animation("normal"+get_color(color))
	
	set_process(true)

func _process(delta):
	if destx == null or desty == null or (destx == x and desty == y): return
	
	var delx = posx - get_pos().x
	var dely = posy - get_pos().y
	
	var speed = Vector2(0, 0)
	if abs(delx) > 20:
		speed.x = 300*(destx - x)
	else:
		set_pos(Vector2(posx, get_pos().y))
		self.x = destx
		
	if abs(dely) > 20:
		speed.y = 300*(desty - y)
	else:
		set_pos(Vector2(get_pos().x, posy))
		self.y = desty
	
	set_pos(get_pos() + speed * delta)

## retorna o numero pq por algum motivo isso ta null

func get_color(n):
	if n == 0:
		return "Blue"
	elif n == 1:
		return "Green"
	elif n == 2:
		return "Orange"
	elif n == 3:
		return "Pink"
	elif n == 4:
		return "Purple"
	elif n == 5:
		return "Yellow"
	

func _on_Candy_input_event( viewport, event, shape_idx ):
	if event.type == InputEvent.SCREEN_TOUCH and event.pressed:
		if sel:
			desel()
			emit_signal("selected",self,false)
		else:
			sel()
			emit_signal("selected",self,true)

func desel():
	sel = false
	get_node("Sel").hide()

func sel():
	sel = true
	get_node("Sel").show()
	
func set_data(x,y):
	self.x = x
	self.y = y
	set_pos(Vector2(62+x*75+75/2,290+y*75+75/2))
	

func move_to(gx,gy):
	destx = gx
	desty = gy
	posx = get_pos().x + (gx - x) * 75
	posy = get_pos().y + (gy - y) * 75

func toString():
	print("(" + str(self.x) + "," + str(self.y) + ") " + str(self.color))
