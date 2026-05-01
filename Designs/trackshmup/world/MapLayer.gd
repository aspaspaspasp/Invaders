extends Node2D

const LocationData = preload("res://world/LocationData.gd")

var locations: Array = []
var _pulse: float    = 0.0

func _process(delta: float) -> void:
	_pulse = fmod(_pulse + delta * 2.2, TAU)
	queue_redraw()

func _draw() -> void:
	var font := ThemeDB.fallback_font
	for loc in locations:
		_draw_marker(loc, font)

func _draw_marker(loc, font: Font) -> void:
	var p: Vector2 = loc.world_pos()
	var locked: bool = not loc.is_unlocked

	if locked:
		var d := 8.0
		var pts := PackedVector2Array([
			p + Vector2(0.0, -d), p + Vector2(d, 0.0),
			p + Vector2(0.0,  d), p + Vector2(-d, 0.0),
		])
		draw_colored_polygon(pts, Color(0.3, 0.3, 0.3, 0.5))
		draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[0]]),
				Color(0.45, 0.45, 0.45, 0.6), 1.0)
		draw_string(font, p + Vector2(-18.0, -d - 4.0), "wave %d" % loc.unlock_wave,
				HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.5, 0.5, 0.5, 0.6))
		return

	var color: Color = LocationData.reward_color(loc.reward)
	if loc.visited:
		color = color.darkened(0.55)

	var glow_r: float = 24.0 + (sin(_pulse) * 5.0 if not loc.visited else 0.0)
	draw_circle(p, glow_r, Color(color.r, color.g, color.b, 0.12))

	var d: float = 14.0 if not loc.visited else 10.0
	var pts := PackedVector2Array([
		p + Vector2(0.0, -d),
		p + Vector2(d,   0.0),
		p + Vector2(0.0,  d),
		p + Vector2(-d,  0.0),
	])
	draw_colored_polygon(pts, color)
	draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[0]]),
			color.lightened(0.3), 1.5)

	var letter: String = loc.loc_name.left(1)
	draw_string(font, p + Vector2(-5.0, 5.0), letter,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 13,
			Color(0.0, 0.0, 0.0, 0.8 if not loc.visited else 0.4))

	var name_color: Color = Color(1.0, 1.0, 1.0, 0.9) if not loc.visited else Color(0.5, 0.5, 0.5, 0.7)
	draw_string(font, p + Vector2(-40.0, -d - 6.0), loc.loc_name,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 11, name_color)

	if not loc.visited:
		draw_string(font, p + Vector2(-28.0, -d + 2.0),
				"[%s]" % LocationData.reward_label(loc.reward),
				HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(color.r, color.g, color.b, 0.8))
