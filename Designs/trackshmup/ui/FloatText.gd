extends Node2D

var amount: int = 1

const DURATION   := 1.3
const RISE_SPEED := 55.0

var _timer: float = 0.0

func _process(delta: float) -> void:
	_timer      += delta
	position.y  -= RISE_SPEED * delta
	queue_redraw()
	if _timer >= DURATION:
		queue_free()

func _draw() -> void:
	var alpha    := 1.0 - (_timer / DURATION)
	var font     := ThemeDB.fallback_font
	var text     := "+%d" % amount
	var text_col := Color(0.35, 1.0, 0.45, alpha)
	var rail_col := Color(0.78, 0.72, 0.56, alpha)

	draw_string(font, Vector2(-24.0, 7.0), text,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 26, text_col)

	# Mini track icon — two short parallel lines after the text
	var ix := -2.0
	draw_line(Vector2(ix, -4.0), Vector2(ix + 16.0, -4.0), rail_col, 3.0)
	draw_line(Vector2(ix,  4.0), Vector2(ix + 16.0,  4.0), rail_col, 3.0)
