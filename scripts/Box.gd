extends Sprite

var x
var y

func set_data(x,y):
	self.x = x
	self.y = y
	set_pos(Vector2(62+x*75+75/2,290+y*75+75/2))
	
