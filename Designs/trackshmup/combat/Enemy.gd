class_name Enemy
extends Area2D

enum Type { GRUNT, SPEEDER, TANK, BOMBER, BRUTE }

var hp:     int   = 2
var max_hp: int   = 2
var speed:  float = 60.0
var damage: int   = 1
var radius: float = 16.0
var color:  Color = Color(0.9, 0.35, 0.1)
var target: Node2D = null
var alive:  bool  = true
var type:   int   = Type.GRUNT

func _ready() -> void:
	collision_layer = 2
	collision_mask  = 0
	monitoring      = false

func setup(t: int, tgt: Node2D) -> void:
	type   = t
	target = tgt
	match type:
		Type.GRUNT:
			hp = 2;  speed = 65.0;  damage = 1; radius = 19.2
			color = Color(0.9, 0.35, 0.1)
		Type.SPEEDER:
			hp = 1;  speed = 125.0; damage = 1; radius = 13.2
			color = Color(1.0, 0.88, 0.1)
		Type.TANK:
			hp = 7;  speed = 32.0;  damage = 2; radius = 31.2
			color = Color(0.55, 0.1, 0.85)
		Type.BOMBER:
			hp = 3;  speed = 88.0;  damage = 2; radius = 15.6
			color = Color(1.0, 0.45, 0.05)
		Type.BRUTE:
			hp = 14; speed = 22.0;  damage = 3; radius = 40.8
			color = Color(0.72, 0.05, 0.15)
	max_hp = hp

	var cs    := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = radius
	cs.shape = shape
	add_child(cs)

func take_hit(dmg: int) -> bool:
	hp -= dmg
	queue_redraw()
	if hp <= 0:
		alive = false
	return hp <= 0

func _process(delta: float) -> void:
	if target == null or not alive:
		return
	position += (target.position - position).normalized() * speed * delta

func _hex_pts() -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 6:
		var a := i * PI / 3.0 + PI / 6.0
		pts.append(Vector2(cos(a), sin(a)) * radius)
	return pts

func _draw() -> void:
	var pts := _hex_pts()
	draw_polygon(pts, PackedColorArray([color]))
	pts.append(pts[0])
	draw_polyline(pts, color.darkened(0.35), 2.0)
	if max_hp > 1 and alive:
		var bw := radius * 2.2
		var bx := -bw * 0.5
		var by := -radius - 8.0
		draw_rect(Rect2(bx, by, bw, 4.0), Color(0.15, 0.15, 0.15, 0.9))
		draw_rect(Rect2(bx, by, bw * float(hp) / float(max_hp), 4.0),
				Color(0.2, 0.88, 0.25, 0.9))
