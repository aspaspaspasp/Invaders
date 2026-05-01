class_name TrackGrid
extends Node2D

const CELL_SIZE := 43

var tracks:       Dictionary = {}  # Vector2i → Array[Vector2i]  (connection dirs)
var switch_states: Dictionary = {} # Vector2i → int

var ghost_cell: Vector2i = Vector2i(-9999, -9999)
var ghost_from: Vector2i = Vector2i(-9999, -9999)

# ── Track API ─────────────────────────────────────────────────────────────────

func has_track(cell: Vector2i) -> bool:
	return tracks.has(cell)

func get_connections(cell: Vector2i) -> Array:
	return tracks.get(cell, [])

func add_connection(cell: Vector2i, dir: Vector2i) -> void:
	if not tracks.has(cell):
		tracks[cell] = []
	var conns: Array = tracks[cell]
	if not conns.has(dir):
		conns.append(dir)
	switch_states.erase(cell)
	queue_redraw()

func place_segment(from_cell: Vector2i, to_cell: Vector2i) -> void:
	var dir := to_cell - from_cell
	add_connection(from_cell, dir)
	add_connection(to_cell, -dir)

func remove_track(cell: Vector2i) -> int:
	var conns := get_connections(cell)
	for d: Vector2i in conns:
		var nb := cell + d
		if tracks.has(nb):
			var nb_conns: Array = tracks[nb]
			nb_conns.erase(-d)
			if nb_conns.is_empty():
				tracks.erase(nb)
				switch_states.erase(nb)
	tracks.erase(cell)
	switch_states.erase(cell)
	queue_redraw()
	return conns.size()

func is_junction(cell: Vector2i) -> bool:
	return get_connections(cell).size() >= 3

func toggle_switch(cell: Vector2i) -> void:
	if not is_junction(cell): return
	var n: int = get_connections(cell).size()
	switch_states[cell] = (switch_states.get(cell, 0) + 1) % n
	queue_redraw()

func set_ghost(cell: Vector2i, from_cell: Vector2i) -> void:
	ghost_cell = cell
	ghost_from = from_cell
	queue_redraw()

func cell_center(cell: Vector2i) -> Vector2:
	return Vector2(cell) * CELL_SIZE + Vector2(CELL_SIZE * 0.5, CELL_SIZE * 0.5)

# ── Train routing ─────────────────────────────────────────────────────────────

func get_exit_dir(cell: Vector2i, entry_dir: Vector2i) -> Vector2i:
	var conns  := get_connections(cell)
	var from_d := -entry_dir
	var exits: Array = []
	for d: Vector2i in conns:
		if d != from_d:
			exits.append(d)
	if exits.is_empty(): return Vector2i.ZERO
	if exits.size() == 1: return exits[0] as Vector2i
	var sw: int      = switch_states.get(cell, 0) % conns.size()
	var selected: Vector2i = conns[sw]
	if selected == from_d: return exits[0] as Vector2i
	return selected

# ── Rendering ─────────────────────────────────────────────────────────────────

func _draw() -> void:
	var s := float(CELL_SIZE)

	# Full grid
	var grid_line := Color(1.0, 1.0, 1.0, 0.06)
	for x: int in 44:
		for y: int in 25:
			draw_rect(Rect2(x * s, y * s, s, s), grid_line, false, 1.0)

	# Track cell backgrounds
	var bg := Color(0.22, 0.18, 0.12, 0.75)
	for cell: Vector2i in tracks:
		draw_rect(Rect2(Vector2(cell) * s, Vector2(s, s)), bg)

	for cell: Vector2i in tracks:
		_draw_cell(cell)

	for cell: Vector2i in tracks:
		if is_junction(cell):
			_draw_switch(cell)

	# Ghost hover highlight
	if ghost_cell != Vector2i(-9999, -9999):
		var gpos := Vector2(ghost_cell) * s
		draw_rect(Rect2(gpos, Vector2(s, s)), Color(0.78, 0.72, 0.56, 0.12))
		draw_rect(Rect2(gpos, Vector2(s, s)), Color(0.78, 0.72, 0.56, 0.25), false, 1.0)
		# Preview the connection that would be placed
		if ghost_from != Vector2i(-9999, -9999):
			var delta := ghost_cell - ghost_from
			if abs(delta.x) <= 1 and abs(delta.y) <= 1 and delta != Vector2i.ZERO:
				_draw_half_at(ghost_cell, -delta, 0.3)

func _draw_cell(cell: Vector2i) -> void:
	var conns := get_connections(cell)
	match conns.size():
		0: return
		1: _draw_half(cell, conns[0] as Vector2i, 1.0)
		2: _draw_pair(cell, conns[0] as Vector2i, conns[1] as Vector2i, 1.0)
		_:
			# Junction: draw switch-selected direction paired with best partner
			var sw: int       = switch_states.get(cell, 0) % conns.size()
			var active: Vector2i = conns[sw]
			var partner := Vector2i.ZERO
			for d: Vector2i in conns:
				if d == active: continue
				if d + active == Vector2i.ZERO:
					partner = d
					break
			if partner == Vector2i.ZERO:
				partner = (conns[0] as Vector2i) if conns[0] != active else (conns[1] as Vector2i)
			_draw_pair(cell, active, partner, 1.0)
			for d: Vector2i in conns:
				if d != active and d != partner:
					_draw_half(cell, d, 0.4)

func _draw_pair(cell: Vector2i, d1: Vector2i, d2: Vector2i, alpha: float) -> void:
	var rail := Color(0.78, 0.72, 0.56, alpha)
	var w    := 4.0
	var off  := float(CELL_SIZE) * 0.15
	var c    := cell_center(cell)
	var half := float(CELL_SIZE) * 0.5
	var p1   := c + Vector2(d1) * half
	var p2   := c + Vector2(d2) * half

	if d1 + d2 == Vector2i.ZERO:
		# Straight through — works for both cardinal and diagonal
		var axis_n := Vector2(d1).normalized()
		var perp_n := Vector2(-axis_n.y, axis_n.x)
		draw_line(p2 - perp_n * off, p1 - perp_n * off, rail, w)
		draw_line(p2 + perp_n * off, p1 + perp_n * off, rail, w)
	elif _is_cardinal(d1) and _is_cardinal(d2):
		# Cardinal 90° curve — arc
		var arc_c  := c + Vector2(d1 + d2) * half
		var angles := _arc_angles(d1 + d2)
		draw_arc(arc_c, half - off, angles[0], angles[1], 16, rail, w)
		draw_arc(arc_c, half + off, angles[0], angles[1], 16, rail, w)
	else:
		# Mixed or diagonal-to-diagonal: two arms from center
		_draw_half_raw(c, d1, half, off, rail, w)
		_draw_half_raw(c, d2, half, off, rail, w)

func _draw_half(cell: Vector2i, d: Vector2i, alpha: float) -> void:
	_draw_half_at(cell, d, alpha)

func _draw_half_at(cell: Vector2i, d: Vector2i, alpha: float) -> void:
	var rail := Color(0.78, 0.72, 0.56, alpha)
	_draw_half_raw(cell_center(cell), d, float(CELL_SIZE) * 0.5,
			float(CELL_SIZE) * 0.15, rail, 4.0)

func _draw_half_raw(c: Vector2, d: Vector2i, half: float, off: float, rail: Color, w: float) -> void:
	var axis_n   := Vector2(d).normalized()
	var perp_n   := Vector2(-axis_n.y, axis_n.x)
	var endpoint := c + Vector2(d) * half
	draw_line(c - perp_n * off, endpoint - perp_n * off, rail, w)
	draw_line(c + perp_n * off, endpoint + perp_n * off, rail, w)

func _draw_switch(cell: Vector2i) -> void:
	var conns := get_connections(cell)
	var sw: int  = switch_states.get(cell, 0) % conns.size()
	var dir: Vector2i = conns[sw]
	var c   := cell_center(cell)
	var tip := c + Vector2(dir).normalized() * float(CELL_SIZE) * 0.38
	draw_circle(c, 8.0, Color(0.05, 0.05, 0.05, 0.85))
	var col := Color(0.25, 0.9, 0.25)
	draw_line(c, tip, col, 3.0)
	draw_circle(tip, 3.5, col)
	draw_circle(c, 3.5, col)

func _is_cardinal(d: Vector2i) -> bool:
	return (d.x == 0) != (d.y == 0)

func _arc_angles(corner: Vector2i) -> Array:
	match corner:
		Vector2i(-1, -1): return [0.0,       PI * 0.5]
		Vector2i( 1, -1): return [PI * 0.5,  PI      ]
		Vector2i( 1,  1): return [PI,        PI * 1.5]
		Vector2i(-1,  1): return [-PI * 0.5, 0.0     ]
	return [0.0, 0.0]
