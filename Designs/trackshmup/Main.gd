extends Node2D

@onready var track_grid:      TrackGrid      = $TrackGrid
@onready var train:           Train          = $Train
@onready var camera:          Camera2D       = $Camera2D
@onready var palette:         Node2D         = $HUD/Palette
@onready var map_layer:       Node2D         = $MapLayer
@onready var track_system:    TrackSystem    = $TrackSystem
@onready var combat_system:   CombatSystem   = $CombatSystem
@onready var location_system: LocationSystem = $LocationSystem

var train_hp:      int    = 5
var prelaunch:     bool   = true
var _lmb_held:     bool   = false
var _float_texts:  Node2D

const FloatTextScript = preload("res://ui/FloatText.gd")

const MAX_HP := 5

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	$Enemies.process_mode = Node.PROCESS_MODE_PAUSABLE
	$Bullets.process_mode = Node.PROCESS_MODE_PAUSABLE

	train.track_grid          = track_grid
	track_system.track_grid   = track_grid
	combat_system.train       = train
	combat_system.enemies     = $Enemies
	combat_system.bullets     = $Bullets
	location_system.train     = train
	location_system.map_layer = map_layer

	_float_texts = Node2D.new()
	add_child(_float_texts)
	camera.position = Vector2(960.0, 540.0)
	_build_world_walls()
	_load_level()

func _build_world_walls() -> void:
	# Thin StaticBody2D boxes on physics layer 1 — trajectory ray bounces off these
	var W := float(44 * TrackGrid.CELL_SIZE)
	var H := float(25 * TrackGrid.CELL_SIZE)
	var t := 10.0  # wall thickness
	var walls := [
		[Vector2(W * 0.5, -t * 0.5),     Vector2(W + t * 2.0, t)],  # top
		[Vector2(W * 0.5, H + t * 0.5),  Vector2(W + t * 2.0, t)],  # bottom
		[Vector2(-t * 0.5, H * 0.5),     Vector2(t, H + t * 2.0)],  # left
		[Vector2(W + t * 0.5, H * 0.5),  Vector2(t, H + t * 2.0)],  # right
	]
	for wdata: Array in walls:
		var body  := StaticBody2D.new()
		var cs    := CollisionShape2D.new()
		var rect  := RectangleShape2D.new()
		rect.size        = wdata[1] as Vector2
		cs.shape         = rect
		body.position    = wdata[0] as Vector2
		body.collision_layer = 1
		body.collision_mask  = 0
		body.add_child(cs)
		add_child(body)

func _load_level() -> void:
	var all_levels: Array = LevelData.all()
	var idx: int  = Engine.get_meta("level_idx", 0)
	idx = clampi(idx, 0, all_levels.size() - 1)
	var level: LevelData = all_levels[idx]

	train_hp  = MAX_HP
	prelaunch = true

	train.gear             = 0
	train.derailed         = false
	train.dead             = false
	train.current_cell     = level.train_start
	train.came_from_cell   = level.train_start - Vector2i(1, 0)
	train.current_dir      = Vector2i(1, 0)
	train.progress         = 0.0

	track_grid.tracks.clear()
	track_grid.switch_states.clear()
	track_grid.queue_redraw()

	for i: int in range(level.starting_track.size() - 1):
		track_grid.place_segment(level.starting_track[i], level.starting_track[i + 1])

	track_system.init_from_level(level)
	location_system.init_from_level(level)
	combat_system.init_from_level(level)

	# Starting location is already "visited" — don't give reward on spawn
	for loc in location_system.locations:
		if loc.cell == level.train_start:
			loc.visited = true

	_refresh_hud()

func _process(delta: float) -> void:
	if get_tree().paused:
		return

	track_system.update(delta)

	# Prelaunch ends when all 10 pre-launch tracks are placed OR player shifts up from N
	if prelaunch:
		if track_system.prelaunch_pool == 0 and train.gear == 0:
			train.gear = 1
		if train.gear != 0:
			prelaunch = false
			track_system.prelaunch = false
		_refresh_hud()
		return

	var game_over := train.derailed or train.dead or combat_system.level_complete
	if not game_over:
		combat_system.update(delta)
		train_hp = maxi(0, train_hp - combat_system.damage_this_frame)
		if train_hp <= 0:
			train.dead = true

		track_system.pool = mini(TrackSystem.MAX_POOL,
				track_system.pool + combat_system.kill_rewards)
		for ev: Dictionary in combat_system.kill_events:
			var ft := FloatTextScript.new() as Node2D
			ft.position = ev["pos"]
			ft.set("amount", ev["amount"])
			_float_texts.add_child(ft)

		location_system.current_wave = combat_system.wave
		location_system.update(delta)
		train_hp = mini(MAX_HP, train_hp + location_system.pending_hp_restore)
		track_system.pool = mini(TrackSystem.MAX_POOL,
				track_system.pool + location_system.pending_track_restore)

	_refresh_hud()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mpos := get_global_mouse_position()
		track_system.update_cursor(mpos)
		if _lmb_held:
			track_system.handle_drag(mpos)

	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				_lmb_held = event.pressed
				if event.pressed:
					track_system.handle_left_click(get_global_mouse_position())
				else:
					track_system.cancel_drag()
			MOUSE_BUTTON_RIGHT:
				if event.pressed:
					track_system.handle_right_click(get_global_mouse_position())

	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_A:
				train.shift_up()
				if prelaunch and train.gear != 0:
					prelaunch = false
					track_system.prelaunch = false
			KEY_Z:
				train.shift_down()
			KEY_T:
				get_tree().reload_current_scene()
			KEY_N:
				if combat_system.level_complete:
					var next: int = Engine.get_meta("level_idx", 0) + 1
					Engine.set_meta("level_idx", next)
					get_tree().reload_current_scene()
			KEY_P: get_tree().paused = not get_tree().paused

func _refresh_hud() -> void:
	palette.prelaunch           = prelaunch
	palette.prelaunch_remaining = track_system.prelaunch_pool
	palette.train_gear          = train.gear
	palette.track_pool          = track_system.pool
	palette.replenish_progress  = track_system.replenish_timer / TrackSystem.REPLENISH_INTERVAL
	palette.train_derailed      = train.derailed or train.dead
	palette.level_complete      = combat_system.level_complete
	palette.train_hp            = train_hp
	palette.max_hp              = MAX_HP
	palette.wave                = combat_system.wave
	palette.wave_total          = combat_system._wave_table.size()
	palette.between_waves       = combat_system.between_waves
	palette.wave_countdown      = combat_system.wave_timer
	palette.notification_line1  = location_system.notification_line1
	palette.notification_line2  = location_system.notification_line2
	palette.notification_timer  = location_system.notification_timer
	palette.level_idx           = Engine.get_meta("level_idx", 0)
	palette.queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0.0, 0.0, 1920.0, 1080.0), Color(0.3, 0.24, 0.16))
