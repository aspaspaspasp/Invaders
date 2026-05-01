class_name LocationSystem
extends Node

const LocationData = preload("res://world/LocationData.gd")

var train:      Train
var map_layer:  Node2D

var locations:             Array  = []
var current_wave:          int    = 0
var notification_line1:    String = ""
var notification_line2:    String = ""
var notification_timer:    float  = 0.0
var pending_hp_restore:    int    = 0
var pending_track_restore: int    = 0

func init_from_level(level: LevelData) -> void:
	locations = level.locations.duplicate()
	map_layer.locations = locations

func update(delta: float) -> void:
	pending_hp_restore    = 0
	pending_track_restore = 0
	if notification_timer > 0.0:
		notification_timer -= delta
	_check_location_visits()

func _check_location_visits() -> void:
	for loc in locations:
		if not loc.is_unlocked:
			if current_wave >= loc.unlock_wave:
				loc.is_unlocked = true
				map_layer.queue_redraw()
			else:
				continue
		if not loc.visited and train.current_cell == loc.cell:
			loc.visited = true
			_apply_reward(loc)
			map_layer.queue_redraw()

func _apply_reward(loc) -> void:
	match loc.reward:
		LocationData.RewardType.STATION:
			pending_track_restore  = 14
			notification_line1 = loc.loc_name
			notification_line2 = "+14 track segments"
		LocationData.RewardType.SUPPLY:
			pending_track_restore  = 16
			notification_line1 = loc.loc_name
			notification_line2 = "+16 track segments"
		LocationData.RewardType.DEPOT:
			pending_hp_restore = 3
			notification_line1 = loc.loc_name
			notification_line2 = "Repaired  (+3 HP)"
		LocationData.RewardType.ARMORY:
			pending_track_restore  = 12
			notification_line1 = loc.loc_name
			notification_line2 = "+12 track segments"
	notification_timer = 4.0
