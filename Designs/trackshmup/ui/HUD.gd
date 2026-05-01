extends Node2D

var train_gear:         int     = 0
var prelaunch:          bool    = true
var prelaunch_remaining:int     = 10
var track_pool:         int     = 0
var replenish_progress: float   = 0.0
var train_derailed:     bool    = false
var level_complete:     bool    = false
var train_hp:           int     = 5
var max_hp:             int     = 5
var wave:               int     = 0
var wave_total:         int     = 0
var between_waves:      bool    = true
var wave_countdown:     float   = 5.0
var notification_line1: String  = ""
var notification_line2: String  = ""
var notification_timer: float   = 0.0
var level_idx:          int     = 0

# Pool bar (bottom-centre)
const POOL_X := 760.0
const POOL_Y := 1080.0 - 80.0
const POOL_W := 400.0
const POOL_H := 56.0

func _draw() -> void:
	var font := ThemeDB.fallback_font

	# ── HP bar ───────────────────────────────────────────────────────────────
	var hx := 30.0
	var hy := 30.0
	draw_string(font, Vector2(hx, hy + 36.0), "HP",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 36, Color(0.75, 0.75, 0.75))
	for i: int in max_hp:
		var filled := i < train_hp
		draw_rect(Rect2(hx + 84.0 + i * 51.0, hy + 3.0, 39.0, 39.0),
				Color(0.85, 0.15, 0.15) if filled else Color(0.25, 0.1, 0.1))

	# ── Wave info ─────────────────────────────────────────────────────────────
	var level_names: Array = ["Open Plains", "The Circuit", "Iron Corridor"]
	var lname: String = level_names[clampi(level_idx, 0, level_names.size() - 1)]
	var wave_str: String
	if level_complete:
		wave_str = "%s — All waves clear!" % lname
	elif wave_total > 0:
		wave_str = "%s — Wave %d / %d" % [lname, wave + 1, wave_total]
	else:
		wave_str = lname
	draw_string(font, Vector2(30.0, 100.0), wave_str,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 32, Color(0.75, 0.75, 0.75))
	if between_waves and not level_complete:
		draw_string(font, Vector2(30.0, 136.0),
				"next wave in %ds" % ceili(wave_countdown),
				HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color(0.45, 0.75, 0.45))

	# ── Pre-launch banner ─────────────────────────────────────────────────────
	if prelaunch:
		var msg1 := "PRE-LAUNCH  —  %d tracks remaining" % prelaunch_remaining
		var msg2 := "A: launch now"
		draw_rect(Rect2(0.0, 460.0, 1920.0, 130.0), Color(0.0, 0.0, 0.0, 0.55))
		draw_string(font, Vector2(0.0, 530.0), msg1,
				HORIZONTAL_ALIGNMENT_CENTER, 1920.0, 52, Color(1.0, 0.88, 0.2))
		draw_string(font, Vector2(0.0, 578.0), msg2,
				HORIZONTAL_ALIGNMENT_CENTER, 1920.0, 32, Color(0.75, 0.75, 0.75))

	# ── Reward notification ───────────────────────────────────────────────────
	if notification_timer > 0.0:
		var alpha := minf(notification_timer, 1.0)
		draw_rect(Rect2(POOL_X - 30.0, 126.0, POOL_W + 60.0, 114.0),
				Color(0.0, 0.0, 0.0, 0.55 * alpha))
		draw_string(font, Vector2(0.0, 186.0), notification_line1,
				HORIZONTAL_ALIGNMENT_CENTER, 1920.0, 45, Color(1.0, 0.92, 0.3, alpha))
		draw_string(font, Vector2(0.0, 234.0), notification_line2,
				HORIZONTAL_ALIGNMENT_CENTER, 1920.0, 36, Color(0.9, 0.9, 0.9, alpha))

	# ── Level complete ────────────────────────────────────────────────────────
	if level_complete:
		var has_next: bool = level_idx + 1 < 3
		var msg := "LEVEL COMPLETE — N: next level  |  T: restart" if has_next \
				else "ALL LEVELS COMPLETE — T: restart"
		draw_rect(Rect2(0.0, 500.0, 1920.0, 100.0), Color(0.0, 0.0, 0.0, 0.55))
		draw_string(font, Vector2(0.0, 567.0), msg,
				HORIZONTAL_ALIGNMENT_CENTER, 1920.0, 54, Color(0.0, 0.0, 0.0, 0.7))
		draw_string(font, Vector2(0.0, 561.0), msg,
				HORIZONTAL_ALIGNMENT_CENTER, 1920.0, 54, Color(0.3, 1.0, 0.4))

	# ── Game-over ─────────────────────────────────────────────────────────────
	elif train_derailed:
		var msg := "DESTROYED — Press T to restart"
		draw_string(font, Vector2(0.0, 549.0), msg,
				HORIZONTAL_ALIGNMENT_CENTER, 1920.0, 54, Color(0.0, 0.0, 0.0, 0.7))
		draw_string(font, Vector2(0.0, 543.0), msg,
				HORIZONTAL_ALIGNMENT_CENTER, 1920.0, 54, Color(1.0, 0.3, 0.3))

	# ── Gear indicator ────────────────────────────────────────────────────────
	var gear_labels: Array = ["R", "N", "1", "2", "3"]
	var gear_cols:   Array = [
		Color(1.0, 0.62, 0.1),   # R — amber
		Color(0.55, 0.55, 0.55), # N — grey
		Color(0.25, 0.65, 1.0),  # 1 — blue
		Color(0.35, 0.85, 1.0),  # 2 — bright cyan
		Color(0.1,  1.0,  0.85), # 3 — teal
	]
	# train_gear: -1=R, 0=N, 1=1st, 2=2nd, 3=3rd → array index = gear + 1
	var active_idx: int = train_gear + 1
	var box_w := 62.0
	var box_h := POOL_H
	var gear_x := POOL_X - 5 * (box_w + 4.0) - 10.0
	for i: int in 5:
		var bx   := gear_x + i * (box_w + 4.0)
		var act  := (i == active_idx)
		var gcol: Color = gear_cols[i]
		draw_rect(Rect2(bx, POOL_Y, box_w, box_h),
				(gcol if act else gcol.darkened(0.65)) * Color(1, 1, 1, 0.88))
		draw_rect(Rect2(bx, POOL_Y, box_w, box_h),
				gcol if act else Color(0.3, 0.3, 0.3, 0.5), false, 2.0 if act else 1.0)
		draw_string(font, Vector2(bx + box_w * 0.5, POOL_Y + 40.0), gear_labels[i],
				HORIZONTAL_ALIGNMENT_CENTER, box_w, 28,
				gcol if act else Color(0.4, 0.4, 0.4))

	draw_string(font, Vector2(gear_x, POOL_Y + box_h + 14.0), "Z ▼          A ▲",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(0.45, 0.45, 0.45))

	# ── Track segment pool ────────────────────────────────────────────────────
	draw_rect(Rect2(POOL_X, POOL_Y, POOL_W, POOL_H),
			Color(0.08, 0.08, 0.08, 0.88))
	draw_rect(Rect2(POOL_X, POOL_Y, POOL_W, POOL_H),
			Color(0.28, 0.28, 0.28, 0.7), false, 1.5)
	draw_string(font, Vector2(POOL_X + 16.0, POOL_Y + 39.0), "TRACK",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(0.55, 0.55, 0.55))
	draw_string(font, Vector2(POOL_X + POOL_W - 60.0, POOL_Y + 44.0), str(track_pool),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 40,
			Color(1.0, 0.35, 0.35) if track_pool == 0 else Color.WHITE)

	# Replenish bar
	draw_rect(Rect2(POOL_X, POOL_Y + POOL_H + 6.0, POOL_W, 8.0),
			Color(0.15, 0.15, 0.15, 0.8))
	draw_rect(Rect2(POOL_X, POOL_Y + POOL_H + 6.0, POOL_W * replenish_progress, 8.0),
			Color(0.35, 0.8, 0.35, 0.9))

	# ── Controls hint ─────────────────────────────────────────────────────────
	draw_string(font, Vector2(POOL_X, POOL_Y - 16.0),
			"A: shift up  Z: shift down  |  P: pause  |  LMB: place / toggle junction  |  RMB: remove  |  T: restart  |  N: next level",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(0.5, 0.5, 0.5, 0.8))
