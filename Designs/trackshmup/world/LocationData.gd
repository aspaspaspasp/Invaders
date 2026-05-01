class_name LocationData
extends RefCounted

enum RewardType { STATION, SUPPLY, DEPOT, ARMORY }

var loc_name:    String
var cell:        Vector2i
var reward:      int
var visited:     bool = false
var unlock_wave: int  = 0
var is_unlocked: bool = true

func _init(n: String, c: Vector2i, r: int, uw: int = 0) -> void:
	loc_name    = n
	cell        = c
	reward      = r
	unlock_wave = uw
	is_unlocked = (uw == 0)

func world_pos() -> Vector2:
	return Vector2(cell) * TrackGrid.CELL_SIZE + Vector2(TrackGrid.CELL_SIZE * 0.5, TrackGrid.CELL_SIZE * 0.5)

static func reward_color(type: int) -> Color:
	match type:
		RewardType.STATION: return Color(0.35, 0.65, 1.0)
		RewardType.SUPPLY:  return Color(0.3,  1.0,  0.45)
		RewardType.DEPOT:   return Color(1.0,  0.35, 0.35)
		RewardType.ARMORY:  return Color(1.0,  0.62, 0.2)
	return Color.WHITE

static func reward_label(type: int) -> String:
	match type:
		RewardType.STATION: return "STATION"
		RewardType.SUPPLY:  return "SUPPLY"
		RewardType.DEPOT:   return "DEPOT"
		RewardType.ARMORY:  return "ARMORY"
	return ""
