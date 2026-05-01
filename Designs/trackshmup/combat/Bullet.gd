class_name Bullet
extends Node2D

const SPEED  := 520.0
const RADIUS := 5.0
const DAMAGE := 1

var alive:    bool    = true
var waypoints: Array  = []   # Array[Vector2] — full trajectory path
var _wp_idx:  int     = 1    # index of the next target waypoint
var velocity: Vector2 = Vector2.ZERO  # kept for trail rendering

func setup(wps: Array) -> void:
	waypoints = wps
	_wp_idx   = 1
	if wps.size() > 0:
		position = wps[0] as Vector2
	if wps.size() >= 2:
		velocity = ((wps[1] as Vector2) - position).normalized() * SPEED


func _process(delta: float) -> void:
	if not alive or _wp_idx >= waypoints.size():
		alive = false
		queue_free()
		return

	var tgt    : Vector2 = waypoints[_wp_idx] as Vector2
	var to_tgt := tgt - position
	var step   := SPEED * delta

	if to_tgt.length() <= step:
		position = tgt
		_wp_idx += 1
		if _wp_idx < waypoints.size():
			velocity = ((waypoints[_wp_idx] as Vector2) - position).normalized() * SPEED
	else:
		velocity  = to_tgt.normalized() * SPEED
		position += velocity * delta

	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, RADIUS, Color(1.0, 0.95, 0.3))
	if velocity.length_squared() > 0.0:
		draw_line(Vector2.ZERO, -velocity.normalized() * 12.0, Color(1.0, 0.7, 0.1, 0.5), 2.0)
