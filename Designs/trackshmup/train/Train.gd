class_name Train
extends Node2D

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE

const SPEED_REV := 0.5
const SPEED_1   := 0.75
const SPEED_2   := 1.3
const SPEED_3   := 2.0

const TRAJ_BOUNCES := 2
const TRAJ_DIST    := 1200.0

var track_grid:      TrackGrid
var current_cell  := Vector2i(5, 9)
var came_from_cell := Vector2i(4, 9)
var current_dir   := Vector2i(1, 0)
var progress      := 0.0
var derailed      := false
var dead          := false
var turret_angle  := 0.0
var gear:              int   = 0
var _last_gear_sign:   int   = 0
var trajectory:        Array = []   # Array[Vector2] world-space waypoints

func shift_up()   -> void: gear = mini(gear + 1, 3)
func shift_down() -> void: gear = maxi(gear - 1, -1)

func _process(delta: float) -> void:
	var stopped := derailed or dead
	var gs: int = sign(gear)
	if gs != _last_gear_sign:
		progress = 0.0
		_last_gear_sign = gs
	if not stopped and gear != 0:
		progress += _speed() * delta
		while progress >= 1.0:
			progress -= 1.0
			_advance()
			if derailed: break
	if not stopped:
		turret_angle = (get_global_mouse_position() - global_position).angle()

	position = _world_pos()
	var facing := (came_from_cell - current_cell) if gear < 0 else current_dir
	rotation   = atan2(float(facing.y), float(facing.x))
	queue_redraw()

func _recalc_trajectory() -> void:
	var dir   := Vector2(cos(turret_angle), sin(turret_angle))
	var start := position + dir * 40.0
	trajectory = _calc_traj(start, dir, TRAJ_BOUNCES, TRAJ_DIST)

func _calc_traj(start: Vector2, dir: Vector2, bounces: int, max_dist: float) -> Array:
	var pts   : Array = [start]
	var space := get_world_2d().direct_space_state
	var pos   := start
	var d     := dir.normalized()
	var rem   := max_dist
	var exclude: Array = []   # RIDs to skip (the surface just bounced off)

	for _b: int in range(bounces + 1):
		var query := PhysicsRayQueryParameters2D.create(pos, pos + d * rem)
		query.collide_with_areas = true
		query.collision_mask     = 1   # layer 1 = walls
		query.exclude            = exclude

		var hit: Dictionary = space.intersect_ray(query)
		if hit.is_empty():
			pts.append(pos + d * rem)
			break

		var hit_pos  : Vector2 = hit["position"]
		var hit_norm : Vector2 = hit["normal"]

		pts.append(hit_pos)
		rem -= pos.distance_to(hit_pos)
		if rem <= 0.0: break

		pos     = hit_pos + hit_norm * 1.0   # nudge outside the surface
		d       = d.reflect(hit_norm)
		exclude = [hit["rid"]]               # don't immediately re-hit same surface

	return pts

func _speed() -> float:
	var base := 0.0
	match gear:
		-1: base = SPEED_REV
		1:  base = SPEED_1
		2:  base = SPEED_2
		3:  base = SPEED_3
	var move_dir := came_from_cell - current_cell if gear < 0 else current_dir
	if move_dir.x != 0 and move_dir.y != 0:
		return base / sqrt(2.0)
	return base

func _advance() -> void:
	if gear == -1: _step_back()
	else:          _step_fwd()

func _step_fwd() -> void:
	var next := current_cell + current_dir
	var exit := track_grid.get_exit_dir(next, current_dir)
	if exit == Vector2i.ZERO:
		derailed = true
		return
	came_from_cell = current_cell
	current_cell   = next
	current_dir    = exit

func _step_back() -> void:
	var delta     := current_cell - came_from_cell
	var back_exit := track_grid.get_exit_dir(came_from_cell, -delta)
	if back_exit == Vector2i.ZERO:
		derailed = true
		return
	var new_came_from := came_from_cell + back_exit
	current_cell      = came_from_cell
	came_from_cell    = new_came_from
	current_dir = track_grid.get_exit_dir(current_cell, -back_exit)

func _world_pos() -> Vector2:
	if gear < 0:
		return track_grid.cell_center(current_cell).lerp(
				track_grid.cell_center(came_from_cell), progress)
	var to := current_cell + current_dir
	return track_grid.cell_center(current_cell).lerp(
			track_grid.cell_center(to), progress)

func _draw() -> void:
	var stopped := derailed or dead
	var body: Color
	if stopped:
		body = Color(0.9, 0.2, 0.2)
	elif gear == -1:
		body = Color(1.0, 0.62, 0.1)
	elif gear == 0:
		body = Color(0.55, 0.55, 0.55)
	elif gear == 2:
		body = Color(0.35, 0.85, 1.0)
	elif gear == 3:
		body = Color(0.1, 1.0, 0.85)
	else:
		body = Color(0.25, 0.65, 1.0)

	draw_rect(Rect2(-22.0, -11.0, 44.0, 22.0), body)
	draw_rect(Rect2(4.0,   -10.0, 14.0,  8.0), body.darkened(0.25))
	draw_rect(Rect2(18.0,  -11.0,  4.0, 22.0), body.lightened(0.3))

	var local_angle := turret_angle - rotation
	var td          := Vector2(cos(local_angle), sin(local_angle))

	draw_circle(Vector2.ZERO, 8.0, Color(0.38, 0.38, 0.48))
	draw_line(Vector2.ZERO, td * 26.0, Color(0.82, 0.82, 0.88), 5.0)
	draw_circle(td * 26.0, 3.5, Color(0.62, 0.62, 0.68))
