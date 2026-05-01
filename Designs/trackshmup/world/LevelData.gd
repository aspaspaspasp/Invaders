class_name LevelData
extends RefCounted

const _LocationData = preload("res://world/LocationData.gd")

var level_name:         String
var train_start:        Vector2i
var starting_track:     Array[Vector2i]
var pool:               int
var locations:          Array        # Array of LocationData
var waves:              Array        # Array of [grunt, speeder, tank]
var between_wave_delay: float

# ── Level definitions ─────────────────────────────────────────────────────────

static func all() -> Array:
	return [level_1(), level_2(), level_3()]

static func level_1() -> LevelData:
	var ld := LevelData.new()
	ld.level_name         = "Open Plains"
	ld.train_start        = Vector2i(3, 12)  # Iron Depot station
	ld.between_wave_delay = 8.0
	ld.pool               = 60

	ld.starting_track = [Vector2i(3, 12), Vector2i(4, 12), Vector2i(5, 12)]

	var L := _LocationData.RewardType
	ld.locations = [
		_LocationData.new("Iron Depot",    Vector2i( 3, 12), L.STATION, 0),
		_LocationData.new("North Station", Vector2i(22,  3), L.SUPPLY,  2),
		_LocationData.new("East Outpost",  Vector2i(40, 12), L.DEPOT,   4),
		_LocationData.new("South Armory",  Vector2i(22, 21), L.ARMORY,  6),
		_LocationData.new("Western Cache", Vector2i( 7, 21), L.STATION, 8),
	]

	ld.waves = [
		# [grunt, speeder, tank, bomber, brute]
		[3, 0, 0, 0, 0],
		[4, 0, 0, 0, 0],
		[4, 2, 0, 0, 0],
		[5, 1, 0, 0, 0],
		[5, 2, 0, 0, 0],
		[6, 0, 1, 0, 0],
		# new waves — bombers arrive, first brute at end
		[4, 3, 0, 2, 0],
		[6, 2, 1, 1, 0],
		[3, 4, 1, 2, 0],
		[6, 3, 1, 2, 0],
		[4, 4, 2, 2, 1],
	]
	return ld

static func level_2() -> LevelData:
	var ld := LevelData.new()
	ld.level_name         = "The Circuit"
	ld.train_start        = Vector2i(5, 4)   # NW Depot station
	ld.between_wave_delay = 6.0
	ld.pool               = 65

	ld.starting_track = [Vector2i(5, 4), Vector2i(6, 4), Vector2i(7, 4)]

	var L := _LocationData.RewardType
	ld.locations = [
		_LocationData.new("NW Depot",      Vector2i( 5,  4), L.STATION, 0),
		_LocationData.new("Central Hub",   Vector2i(21, 12), L.SUPPLY,  3),
		_LocationData.new("NE Cache",      Vector2i(36,  4), L.STATION, 5),
		_LocationData.new("SE Armory",     Vector2i(36, 20), L.ARMORY,  8),
		_LocationData.new("SW Outpost",    Vector2i( 5, 20), L.DEPOT,   11),
	]

	ld.waves = [
		# [grunt, speeder, tank, bomber, brute]
		[3, 0, 0, 0, 0],
		[4, 1, 0, 0, 0],
		[4, 2, 0, 0, 0],
		[6, 2, 0, 0, 0],
		[5, 3, 0, 2, 0],
		[6, 2, 1, 2, 0],
		[8, 3, 0, 2, 0],
		[6, 4, 1, 3, 0],
		# new waves — brutes join
		[8, 4, 2, 2, 1],
		[5, 5, 2, 4, 1],
		[10, 4, 2, 3, 1],
		[8, 5, 3, 3, 2],
		[10, 6, 2, 4, 2],
	]
	return ld

static func level_3() -> LevelData:
	var ld := LevelData.new()
	ld.level_name         = "Iron Corridor"
	ld.train_start        = Vector2i(3, 12)  # Far Left depot
	ld.between_wave_delay = 5.0
	ld.pool               = 50

	ld.starting_track = [Vector2i(3, 12), Vector2i(4, 12), Vector2i(5, 12)]

	var L := _LocationData.RewardType
	ld.locations = [
		_LocationData.new("Far Left",      Vector2i( 3, 12), L.DEPOT,    0),
		_LocationData.new("NW Station",    Vector2i( 5,  3), L.STATION,  3),
		_LocationData.new("NE Station",    Vector2i(40,  3), L.STATION,  7),
		_LocationData.new("South Armory",  Vector2i(21, 21), L.ARMORY,  10),
		_LocationData.new("Far Right",     Vector2i(40, 12), L.SUPPLY,  13),
	]

	ld.waves = [
		# [grunt, speeder, tank, bomber, brute]
		[ 4, 0, 0, 0, 0],
		[ 5, 1, 0, 0, 0],
		[ 4, 3, 0, 2, 0],
		[ 5, 2, 1, 1, 0],
		[ 6, 3, 1, 3, 0],
		[ 8, 4, 1, 2, 0],
		[ 6, 5, 2, 3, 1],
		[10, 4, 2, 2, 1],
		[ 8, 6, 3, 4, 1],
		[12, 5, 3, 3, 2],
		# new waves — escalating chaos
		[10, 6, 4, 4, 2],
		[12, 6, 3, 5, 2],
		[ 8, 8, 4, 5, 3],
		[14, 6, 4, 4, 3],
		[12, 8, 5, 6, 4],
	]
	return ld
