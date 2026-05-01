class_name TrackSystem
extends Node

const MAX_POOL           := 60
const REPLENISH_INTERVAL := 10.0
const PRELAUNCH_TRACKS   := 10

var track_grid:      TrackGrid
var pool:            int   = 25
var replenish_timer: float = 0.0
var prelaunch:       bool  = true
var prelaunch_pool:  int   = PRELAUNCH_TRACKS

var _last_drag_cell: Vector2i = Vector2i(-9999, -9999)

func init_from_level(level: LevelData) -> void:
	pool           = level.pool
	prelaunch      = true
	prelaunch_pool = PRELAUNCH_TRACKS

func update(delta: float) -> void:
	if prelaunch: return
	replenish_timer += delta
	if replenish_timer >= REPLENISH_INTERVAL:
		replenish_timer -= REPLENISH_INTERVAL
		pool = mini(pool + 1, MAX_POOL)

func cancel_drag() -> void:
	_last_drag_cell = Vector2i(-9999, -9999)

func handle_left_click(world_pos: Vector2) -> void:
	var cell := _cell_at(world_pos)
	if cell == Vector2i(-9999, -9999): return
	if track_grid.is_junction(cell):
		track_grid.toggle_switch(cell)
		_last_drag_cell = Vector2i(-9999, -9999)
		return
	_last_drag_cell = cell

func handle_drag(world_pos: Vector2) -> void:
	var cell := _cell_at(world_pos)
	if cell == Vector2i(-9999, -9999): return
	if cell == _last_drag_cell: return
	if _last_drag_cell != Vector2i(-9999, -9999):
		var delta := cell - _last_drag_cell
		if abs(delta.x) <= 1 and abs(delta.y) <= 1:
			_try_connect(_last_drag_cell, cell)
	_last_drag_cell = cell

func handle_right_click(world_pos: Vector2) -> void:
	var cell := _cell_at(world_pos)
	if cell == Vector2i(-9999, -9999): return
	if not track_grid.has_track(cell): return
	var refund := track_grid.remove_track(cell)
	if prelaunch:
		prelaunch_pool = mini(prelaunch_pool + refund, PRELAUNCH_TRACKS)
	else:
		pool = mini(pool + refund, MAX_POOL)

func update_cursor(world_pos: Vector2) -> void:
	var cell := _cell_at(world_pos)
	track_grid.set_ghost(cell, _last_drag_cell)

func _try_connect(from_cell: Vector2i, to_cell: Vector2i) -> void:
	var dir := to_cell - from_cell
	# Already connected?
	if track_grid.get_connections(from_cell).has(dir): return
	var can_place := prelaunch_pool > 0 if prelaunch else pool > 0
	if not can_place: return
	track_grid.add_connection(from_cell, dir)
	track_grid.add_connection(to_cell, -dir)
	if prelaunch:
		prelaunch_pool -= 1
	else:
		pool -= 1

func _cell_at(world_pos: Vector2) -> Vector2i:
	var s  := float(TrackGrid.CELL_SIZE)
	var cx := floori(world_pos.x / s)
	var cy := floori(world_pos.y / s)
	if cx < 0 or cx >= 44 or cy < 0 or cy >= 25:
		return Vector2i(-9999, -9999)
	return Vector2i(cx, cy)
