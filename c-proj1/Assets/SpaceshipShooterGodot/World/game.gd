extends Node2D

# ── Constants ─────────────────────────────────────────────────────────────────
const W = 480
const H = 640
const ANIM_RATE       = 5
const WAVE_INTRO_DUR  = 60
const CARDS_TO_END    = 7
const EVO_CARDS       = 5   # cards collected needed for evolution
const CARRIER_COUNT   = 2   # enemies per spawn that carry a droppable card
const DROP_RATE       = 0.20

const WHITE    := Color(1, 1, 1)
const YELLOW   := Color(1, 1, 0)
const RED      := Color(0.863, 0.118, 0.118)
const CYAN     := Color(0, 0.863, 0.863)
const DARK_BG  := Color(0.039, 0.039, 0.118)

const CARD_COLORS := {
	"shoot":   Color(0.9,  0.1,   0.1),
	"heal":    Color(0.235,0.863, 0.392),
	"special": Color(0.706,0.235, 1.0),
	"energy":  Color(1.0,  0.863, 0.0),
}

const WAVE_NAMES := [
	"THE VANGUARD","TWIN TOWERS","THE ARMADA","THE DIAMOND","THREE COLUMNS",
	"THE WINGS","THE CROSS","THE SWARM","THE PHALANX","THE GAUNTLET",
]

const WAVE_CONFIGS := [
	# 1: THE VANGUARD
	{"movement":"D","descent_speed":0.54,"shoot_interval":36,"entry_stagger":8,"enemies":[
		[240,90,"e_sml"],[185,145,"e_sml"],[295,145,"e_sml"],
		[130,200,"e_sml"],[240,200,"e_sml"],[350,200,"e_sml"],
		[75,255,"e_sml"],[185,255,"e_sml"],[295,255,"e_sml"],[405,255,"e_sml"],
		[75,310,"e_sml"],[185,310,"e_sml"],[240,310,"e_sml"],[295,310,"e_sml"],[405,310,"e_sml"]]},
	# 2: TWIN TOWERS
	{"movement":"D","descent_speed":0.59,"shoot_interval":28,"entry_stagger":6,"enemies":[
		[90,90,"e_med"],[90,145,"e_med"],[90,200,"e_med"],[90,255,"e_med"],[90,310,"e_med"],
		[390,90,"e_med"],[390,145,"e_med"],[390,200,"e_med"],[390,255,"e_med"],[390,310,"e_med"],
		[185,170,"e_sml"],[240,170,"e_sml"],[295,170,"e_sml"],
		[155,130,"e_sml"],[325,130,"e_sml"],[155,215,"e_sml"],[325,215,"e_sml"]]},
	# 3: THE ARMADA
	{"movement":"D","descent_speed":0.50,"shoot_interval":20,"entry_stagger":4,"enemies":[
		[60,80,"e_big"],[120,80,"e_big"],[180,80,"e_big"],[240,80,"e_big"],[300,80,"e_big"],[360,80,"e_big"],[420,80,"e_big"],
		[60,135,"e_med"],[120,135,"e_med"],[180,135,"e_med"],[240,135,"e_med"],[300,135,"e_med"],[360,135,"e_med"],[420,135,"e_med"],
		[60,190,"e_sml"],[120,190,"e_sml"],[180,190,"e_sml"],[240,190,"e_sml"],[300,190,"e_sml"],[360,190,"e_sml"],[420,190,"e_sml"],
		[90,245,"e_med"],[165,245,"e_med"],[240,245,"e_med"],[315,245,"e_med"],[390,245,"e_med"],
		[120,300,"e_sml"],[210,300,"e_sml"],[270,300,"e_sml"],[360,300,"e_sml"]]},
	# 4: THE DIAMOND
	{"movement":"D","h_speed":0.0,"descent_speed":0.45,"shoot_interval":32,"entry_stagger":7,"enemies":[
		[240,70,"e_big"],
		[160,120,"e_med"],[240,120,"e_med"],[320,120,"e_med"],
		[80,175,"e_big"],[160,175,"e_med"],[240,175,"e_med"],[320,175,"e_med"],[400,175,"e_big"],
		[160,230,"e_med"],[240,230,"e_med"],[320,230,"e_med"],[240,285,"e_big"],
		[240,35,"e_sml"],[120,90,"e_sml"],[360,90,"e_sml"],
		[40,175,"e_sml"],[440,175,"e_sml"],[120,260,"e_sml"],[360,260,"e_sml"],[240,320,"e_sml"]]},
	# 5: THREE COLUMNS
	{"movement":"D","h_speed":0.0,"descent_speed":0.50,"shoot_interval":28,"entry_stagger":5,"enemies":[
		[100,60,"e_sml"],[240,60,"e_med"],[380,60,"e_sml"],[100,90,"e_sml"],[240,90,"e_med"],[380,90,"e_sml"],
		[100,120,"e_sml"],[240,120,"e_med"],[380,120,"e_sml"],[100,150,"e_sml"],[240,150,"e_med"],[380,150,"e_sml"],
		[100,180,"e_sml"],[240,180,"e_med"],[380,180,"e_sml"],[100,210,"e_sml"],[240,210,"e_med"],[380,210,"e_sml"],
		[100,240,"e_sml"],[240,240,"e_med"],[380,240,"e_sml"],[100,270,"e_sml"],[240,270,"e_med"],[380,270,"e_sml"],
		[100,300,"e_sml"],[240,300,"e_med"],[380,300,"e_sml"]]},
	# 6: THE WINGS
	{"movement":"D","h_speed":0.0,"descent_speed":0.54,"shoot_interval":26,"entry_stagger":6,"enemies":[
		[45,85,"e_big"],[90,125,"e_big"],[45,165,"e_big"],[90,205,"e_big"],[45,245,"e_big"],
		[435,85,"e_big"],[390,125,"e_big"],[435,165,"e_big"],[390,205,"e_big"],[435,245,"e_big"],
		[240,65,"e_med"],[240,110,"e_med"],[240,155,"e_med"],[240,200,"e_med"],[240,245,"e_med"],[240,290,"e_med"],
		[155,100,"e_sml"],[325,100,"e_sml"],[155,170,"e_sml"],[325,170,"e_sml"],
		[155,240,"e_sml"],[325,240,"e_sml"],[155,310,"e_sml"],[325,310,"e_sml"]]},
	# 7: THE CROSS
	{"movement":"D","descent_speed":0.63,"shoot_interval":24,"entry_stagger":5,"enemies":[
		[240,55,"e_big"],
		[210,100,"e_sml"],[240,100,"e_sml"],[270,100,"e_sml"],
		[210,130,"e_sml"],[240,130,"e_sml"],[270,130,"e_sml"],
		[60,158,"e_med"],[120,158,"e_med"],[180,158,"e_med"],[240,158,"e_med"],[300,158,"e_med"],[360,158,"e_med"],[420,158,"e_med"],
		[60,192,"e_med"],[120,192,"e_med"],[180,192,"e_med"],[240,192,"e_med"],[300,192,"e_med"],[360,192,"e_med"],[420,192,"e_med"],
		[210,225,"e_sml"],[240,225,"e_sml"],[270,225,"e_sml"],[240,260,"e_sml"]]},
	# 8: THE SWARM
	{"movement":"D","descent_speed":0.68,"shoot_interval":22,"entry_stagger":4,"enemies":[
		[65,75,"e_sml"],[100,95,"e_sml"],[75,120,"e_sml"],[110,140,"e_sml"],[60,165,"e_sml"],
		[95,185,"e_sml"],[80,210,"e_sml"],[115,225,"e_sml"],[65,250,"e_sml"],[100,265,"e_sml"],
		[210,65,"e_sml"],[245,80,"e_sml"],[220,105,"e_sml"],[255,125,"e_sml"],[205,150,"e_sml"],
		[250,165,"e_sml"],[215,190,"e_sml"],[255,205,"e_sml"],[210,230,"e_sml"],[250,245,"e_sml"],
		[365,75,"e_sml"],[400,95,"e_sml"],[375,120,"e_sml"],[410,140,"e_sml"],[360,165,"e_sml"],
		[395,185,"e_sml"],[380,210,"e_sml"],[415,225,"e_sml"],[365,250,"e_sml"],[400,265,"e_sml"]]},
	# 9: THE PHALANX
	{"movement":"D","h_speed":0.0,"descent_speed":0.63,"shoot_interval":20,"entry_stagger":4,"enemies":[
		[45,65,"e_big"],[117,65,"e_big"],[189,65,"e_big"],[261,65,"e_big"],[333,65,"e_big"],[405,65,"e_big"],
		[45,115,"e_med"],[117,115,"e_med"],[189,115,"e_med"],[261,115,"e_med"],[333,115,"e_med"],[405,115,"e_med"],
		[45,165,"e_big"],[117,165,"e_big"],[189,165,"e_big"],[261,165,"e_big"],[333,165,"e_big"],[405,165,"e_big"],
		[45,215,"e_med"],[117,215,"e_med"],[189,215,"e_med"],[261,215,"e_med"],[333,215,"e_med"],[405,215,"e_med"],
		[45,265,"e_sml"],[117,265,"e_sml"],[189,265,"e_sml"],[261,265,"e_sml"],[333,265,"e_sml"],[405,265,"e_sml"]]},
	# 10: THE GAUNTLET
	{"movement":"D","descent_speed":0.72,"shoot_interval":16,"entry_stagger":3,"entry_speed":2.7,"enemies":[
		[60,65,"e_big"],[120,65,"e_big"],[180,65,"e_big"],[240,65,"e_big"],[300,65,"e_big"],[360,65,"e_big"],[420,65,"e_big"],
		[60,108,"e_med"],[120,108,"e_med"],[180,108,"e_med"],[240,108,"e_med"],[300,108,"e_med"],[360,108,"e_med"],[420,108,"e_med"],
		[60,151,"e_sml"],[120,151,"e_sml"],[180,151,"e_sml"],[240,151,"e_sml"],[300,151,"e_sml"],[360,151,"e_sml"],[420,151,"e_sml"],
		[60,194,"e_big"],[120,194,"e_big"],[180,194,"e_big"],[240,194,"e_big"],[300,194,"e_big"],[360,194,"e_big"],[420,194,"e_big"],
		[60,237,"e_med"],[120,237,"e_med"],[180,237,"e_med"],[240,237,"e_med"],[300,237,"e_med"],[360,237,"e_med"],[420,237,"e_med"],
		[60,280,"e_sml"],[120,280,"e_sml"],[180,280,"e_sml"],[240,280,"e_sml"],[300,280,"e_sml"],[360,280,"e_sml"],[420,280,"e_sml"],
		[90,323,"e_big"],[165,323,"e_big"],[240,323,"e_big"],[315,323,"e_big"],[390,323,"e_big"]]},
]

# HP for all enemies per wave (index 0 = wave 1)
const WAVE_HP := [3, 4, 5, 7, 9, 12, 15, 18, 22, 25]

const CARD_DATA := [
	{"id":"main_shot","name":"MAIN SHOT","category":"shoot","cycle_time":50,"energy":0,"effect":"main_shot","params":{"offset_y":-20,"vy":-9.7,"interval":12},"droppable":true},
	{"id":"spread_shot","name":"FRONT SPREAD","category":"shoot","cycle_time":55,"energy":-2,"effect":"spread_front","params":{"offset_y":-20,"angle_deg":60,"speed":9.7},"droppable":true},
	{"id":"rapid_shot","name":"HOMING SHOT","category":"shoot","cycle_time":45,"energy":-1,"effect":"homing","params":{"offset_y":-20,"speed":8.5,"steer":0.06,"spread_deg":24.0},"droppable":true},
	{"id":"side_spread","name":"SIDE SPREAD","category":"shoot","cycle_time":55,"energy":-2,"effect":"spread_sides","params":{"angle_deg":30,"speed":9.7},"droppable":true},
	{"id":"heal","name":"HEAL","category":"heal","cycle_time":100,"energy":-2,"effect":"heal","params":{},"droppable":true},
	{"id":"energy_cell","name":"ENERGY CELL","category":"energy","cycle_time":60,"energy":2,"effect":"passive","params":{},"droppable":true},
]

# ── Sprites ───────────────────────────────────────────────────────────────────
var _spr := {}      # key → Array[AtlasTexture]
var _font : FontFile

# ── Audio ─────────────────────────────────────────────────────────────────────
var _snd_pshoot : AudioStreamPlayer
var _snd_expl   : AudioStreamPlayer
var _snd_wave   : AudioStreamPlayer
var _muted      := true

# ── State ─────────────────────────────────────────────────────────────────────
enum GS {MENU,WAVE_INTRO,PLAYING,CARD_SELECT,CARD_FORGE,CARD_ARRANGE,
		 BOSS_INTRO,BOSS,BOSS_DEATH,GAME_OVER,WIN,PAUSED,CARD_OP,EVO_FLASH,CARD_REPLACE}
var _st      := GS.MENU
var _prev_st := GS.PLAYING

# ── Game vars ─────────────────────────────────────────────────────────────────
var _player       = null
var _fleet        = null
var _boss         = null
var _boss_minions = null
var _boss_timer   := 0
var _boss_dq      := []    # [[timer,x,y,enemies_to_kill],...]
var _pbullets     := []
var _ebullets     := []
var _expls        := []
var _cdrops       := []
var _collected    := []    # cards collected this wave
var _card_drop_queue      : Array = []
var _replace_card    : Dictionary = {}
var _replace_cursor  := 0
var _score        := 0
var _wave         := 0
var _wave_timer          := 0
var _wave_carrier_slots  : Array = []
var _kills_this_spawn    := 0
var _respawns_no_kill    := 0
var _shake        := 0
var _menu_sel     := 0
var _pause_sel    := 0
var _csel_cursor  := 0
var _csel_chosen  := []
var _arr_cursor        := 0
var _arr_held                   # null or int index
var _arr_from_playing  := false
var _arr_focus         := 1     # 0 = card pick section, 1 = loop section

# Card operation state (CARD_OP)
var _card_op_type   := ""    # "deck_remove","deck_fuse","deck_upgrade"
var _card_op_cursor := 0
var _card_op_sel1   := -1    # forge: first selected loop index
var _card_op_card   : Dictionary = {}  # the consumed manipulation card
var _card_op_msg    := ""    # feedback message

# Card forge screen state (CARD_FORGE)
var _cforge_cursor      := 0
var _cforge_sel1        := -1
var _cforge_flash_timer := 0   # 60→0, blink result card for 1s
var _cforge_result_idx  := 0   # loop index of the merged card
var _cforge_result      : Dictionary = {}
var _cforge_msg         := ""

var _droppable_cards  : Array = []
var _evo_kills        := 0      # 0–25
var _evo_ready        := false  # forge unlocked in arrange
var _evo_flash_timer  := 0      # counts 120→0 during EVO_FLASH
var _float_texts     : Array = []  # [{x,y,text,color,timer,total,size}, ...]
var _muzzle_flashes  : Array = []  # [{x,y,scale,color,timer,total}, ...]
var _ship_flash_timer := 0
var _ship_flash_col  := Color.WHITE
var _draw_sox        := 0.0   # current frame shake offset, used by draw helpers
var _draw_soy        := 0.0
var _stars           : Array = []  # [{x,y,r,b}] r=radius, b=brightness

# ── Inner class: BulletData ───────────────────────────────────────────────────
class BulletData:
	var x   : float
	var y   : float
	var vx  : float
	var vy  : float
	var kind  : String  # "player" or "enemy"
	var tick  : int   = 0
	var fi    : int   = 0
	var homing: bool  = false
	var steer : float = 0.06
	var bscale: float = 1.0

	func init(px:float,py:float,pvx:float,pvy:float,k:String) -> void:
		x=px; y=py; vx=pvx; vy=pvy; kind=k

	func update() -> void:
		x += vx; y += vy
		tick += 1
		if tick >= 5: tick=0; fi=(fi+1)%2

	func off_screen() -> bool:
		return y < -10 or y > H+10 or x < -10 or x > W+10

	func rect() -> Rect2:
		return Rect2(x-4, y-8, 8, 16)

	func hit_rect() -> Rect2:
		if homing: return Rect2(x-8, y-16, 16, 32)
		return Rect2(x-4, y-8, 8, 16)

# ── Inner class: EnemyData ────────────────────────────────────────────────────
class EnemyData:
	const ENTRY_SPEED := 3.0
	const MAX_HP      := {"e_sml":2,"e_med":3,"e_big":5}
	const N_FRAMES    := {"e_sml":2,"e_med":4,"e_big":2}
	const FLASH_DUR   := 12

	var x           : float
	var y           : float
	var target_x    : float
	var target_y    : float
	var key         : String
	var alive       := true
	var hp          : int
	var flash_timer := 0
	var entry_delay : int
	var delay_timer := 0
	var in_formation:= false
	var entry_speed := ENTRY_SPEED
	var offset_x    := 0.0
	var patrol_x    : float
	var patrol_range:= 55.0
	var patrol_dx   := 1.0
	var carries_card:= false
	var charging    := false

	func init(tx:float,ty:float,k:String,ed:int) -> void:
		target_x=tx; target_y=ty; key=k
		x=tx; y=-50.0
		hp=MAX_HP[k]; entry_delay=ed
		patrol_x=tx

	func update_entry(offset_y: float = 0.0) -> void:
		if in_formation: return
		if delay_timer < entry_delay: delay_timer+=1; return
		var actual_target = target_y + offset_y
		var dy = actual_target - y
		if abs(dy) <= entry_speed:
			y = actual_target; in_formation = true
		else:
			y += entry_speed

	func hit(dmg: int = 1) -> bool:
		hp -= dmg
		flash_timer = FLASH_DUR
		if hp <= 0: alive = false; return true
		return false

	func rect() -> Rect2:
		return Rect2(x-16, y-16, 32, 32)

# ── Inner class: FleetData ────────────────────────────────────────────────────
class FleetData:
	var movement       : String
	var step_down      : float
	var shoot_interval : int
	var enemies        : Array  # Array[EnemyData]
	var total          : int
	var formation_half_w: float
	var anchor_x       : float
	var anchor_dx      : float
	var formation_offset_y := 0.0
	var sine_t         := 0.0
	var sine_center    : float
	var sine_amplitude : float
	var sine_frequency : float
	var descent_speed  : float
	var scattered      := false
	var shoot_timer    := 0
	var anim_tick      := 0
	var frame_idx      := 0
	var tick           := 0
	var pending_shots  := []   # [[fire_at, x, y], ...]

	func setup(cfg: Dictionary) -> void:
		movement       = cfg.get("movement","A")
		step_down      = float(cfg.get("step_down",18))
		shoot_interval = int(cfg.get("shoot_interval",90))
		sine_amplitude = float(cfg.get("sine_amplitude",60))
		sine_frequency = float(cfg.get("sine_frequency",0.02))
		descent_speed  = float(cfg.get("descent_speed",0.4))
		anchor_dx      = float(cfg.get("h_speed",1.0))
		var patrol_range = float(cfg.get("patrol_range",55))
		var h_speed      = float(cfg.get("h_speed",1.0))
		var stagger      = int(cfg.get("entry_stagger",8))
		var esp          = float(cfg.get("entry_speed",EnemyData.ENTRY_SPEED))

		enemies = []
		var edefs : Array = cfg["enemies"]
		for i in range(edefs.size()):
			var ed = EnemyData.new()
			ed.init(float(edefs[i][0]), float(edefs[i][1]), edefs[i][2], i*stagger)
			ed.entry_speed = esp
			enemies.append(ed)
		total = enemies.size()

		var xs = enemies.map(func(e): return e.target_x)
		var cx = xs.reduce(func(a,b): return a+b, 0.0) / xs.size()
		var mx = xs.reduce(func(a,b): return max(a,b), xs[0])
		var mn = xs.reduce(func(a,b): return min(a,b), xs[0])
		formation_half_w = (mx - mn) / 2.0 + 16.0
		anchor_x  = cx
		sine_center = cx

		var min_ty = enemies.map(func(e): return e.target_y).reduce(func(a,b): return min(a,b), enemies[0].target_y)
		for e in enemies:
			e.y = -50.0 - (e.target_y - min_ty)
			e.offset_x     = e.target_x - cx
			e.patrol_x     = e.target_x
			e.patrol_range = patrol_range
			e.patrol_dx    = h_speed * (1.0 if randf() > 0.5 else -1.0)

	func alive_enemies() -> Array:
		return enemies.filter(func(e): return e.alive)

	func all_in_formation() -> bool:
		return enemies.all(func(e): return (not e.alive) or e.in_formation)

	func _move(living: Array) -> void:
		match movement:
			"A":
				anchor_x += anchor_dx
				if anchor_x + formation_half_w >= W or anchor_x - formation_half_w <= 0:
					anchor_dx *= -1
					for e in living: e.y += step_down
				for e in living: e.x = anchor_x + e.offset_x
			"B":
				sine_t += 1
				anchor_x = sine_center + sine_amplitude * sin(sine_t * sine_frequency)
				for e in living: e.x = anchor_x + e.offset_x
			"C":
				for e in living:
					e.x += e.patrol_dx
					var lo = e.patrol_x - e.patrol_range
					var hi = e.patrol_x + e.patrol_range
					if e.x >= hi or e.x <= lo:
						e.patrol_dx *= -1
						e.x = clamp(e.x, lo, hi)
			"D":
				for e in living: e.y += EnemyData.ENTRY_SPEED
				formation_offset_y += EnemyData.ENTRY_SPEED
			"E":
				var alive_ratio = float(living.size()) / float(total)
				if not scattered and alive_ratio <= 0.5: scattered = true
				if not scattered:
					anchor_x += anchor_dx
					if anchor_x + formation_half_w >= W or anchor_x - formation_half_w <= 0:
						anchor_dx *= -1
						for e in living: e.y += step_down
					for e in living: e.x = anchor_x + e.offset_x
				else:
					for e in living:
						e.x += e.patrol_dx
						var lo = e.patrol_x - e.patrol_range
						var hi = e.patrol_x + e.patrol_range
						if e.x >= hi or e.x <= lo:
							e.patrol_dx *= -1
							e.x = clamp(e.x, lo, hi)

	func _separate(living: Array) -> void:
		var MIN_H := 36.0
		var MIN_V := 34.0
		for _pass in range(4):
			for i in range(living.size()):
				for j in range(i+1, living.size()):
					var ei = living[i]; var ej = living[j]
					if abs(ei.y - ej.y) >= MIN_V: continue
					var dx = ej.x - ei.x
					var overlap = MIN_H - abs(dx)
					if overlap <= 0: continue
					var push = overlap/2.0 + 0.5
					if dx >= 0:
						ei.x -= push; ej.x += push
						if ei.patrol_dx > 0: ei.patrol_dx *= -1
						if ej.patrol_dx < 0: ej.patrol_dx *= -1
					else:
						ei.x += push; ej.x -= push
						if ei.patrol_dx < 0: ei.patrol_dx *= -1
						if ej.patrol_dx > 0: ej.patrol_dx *= -1
		var half := 16.0
		for e in living: e.x = clamp(e.x, half, W-half)

	# Returns array of BulletData
	func update(out_bullets: Array) -> void:
		var living = alive_enemies()
		if living.is_empty(): return
		for e in living:
			if e.flash_timer > 0: e.flash_timer -= 1
			e.update_entry(formation_offset_y)
		var formed = living.filter(func(e): return e.in_formation and not e.charging)
		if not formed.is_empty():
			_move(formed)
			_separate(formed)

		tick        += 1
		shoot_timer += 1
		anim_tick   += 1
		if anim_tick >= 5: anim_tick=0; frame_idx+=1

		# pending burst shots
		var still_pending = []
		for entry in pending_shots:
			if tick >= entry[0]:
				var b = BulletData.new(); b.init(entry[1], entry[2], 0, 4.8, "enemy")
				out_bullets.append(b)
			else:
				still_pending.append(entry)
		pending_shots = still_pending

		if shoot_timer >= shoot_interval:
			if not living.is_empty():
				shoot_timer = 0
				var shooter = living[randi() % living.size()]
				var sx = shooter.x; var sy = shooter.y + 10
				if shooter.key == "e_sml":
					var b = BulletData.new(); b.init(sx, sy, 0, 4.8, "enemy"); out_bullets.append(b)
				elif shooter.key == "e_med":
					for vx in [-2.4, 0.0, 2.4]:
						var b = BulletData.new(); b.init(sx, sy, vx, 4.8, "enemy"); out_bullets.append(b)
				else:  # e_big burst
					for i in range(3):
						pending_shots.append([tick + i*8, sx, sy])

# ── Inner class: PlayerData ───────────────────────────────────────────────────
class PlayerData:
	const SPEED         := 4.4
	const SHOOT_CD      := 3
	const SHIP_FRAMES   := {"default":[2,7],"left":[0,5],"right":[4,9]}
	const DASH_SPEED    := 13.0
	const DASH_FRAMES   := 10
	const DASH_CD_MAX   := 50

	var x          := float(W) / 2.0
	var y          := float(H) - 60.0
	var base_max_lives := 3
	var max_lives  := 3
	var lives      := 3.0
	var invincible := 0
	var facing     := "default"
	var tick       := 0
	var fi         := 0
	var cooldown   := 0
	const MAX_LOOP := 5
	var loop       : Array  # Array of card dicts (shoot only)
	var passives   : Array  # Array of passive cards (heal/energy, max 2)
	var loop_idx   := 0
	var loop_timer := 0
	var loop_flash := 0
	var loop_flash_idx := -1
	var max_energy := 10
	var energy_pool:= 10
	var pending_bullets: Array = []  # [[frames_left,ox,oy,vy,vx],...]
	var salvo_charge   := 0
	var salvo_cd       := 0
	var salvo_queue    : Array = []   # [[delay,[(vx,vy),...]],...]
	var vel_x := 0.0
	var vel_y := 0.0
	var hit_expl_timer := 0  # frames remaining for hit explosion
	var hit_expl_x    := 0.0
	var hit_expl_y    := 0.0
	var hit_expl_fi   := 0
	var heal_events   : Array = []  # [[amount, gave_max_hp], ...]
	var muzzle_events : Array = []  # [{x,y,scale,category}, ...]
	var dash_timer    := 0
	var dash_vx       := 0.0
	var dash_cd       := 0
	var dash_trail    : Array = []  # [{x,y,fi,t}]

	var _W: float = W
	var _H: float = H

	func init() -> void:
		x = _W / 2.0; y = _H - 60.0
		base_max_lives=3; max_lives=3; lives=3.0; invincible=0
		facing="default"; tick=0; fi=0; cooldown=0
		loop=[]; passives=[]; loop_idx=0; loop_timer=0; loop_flash=0; loop_flash_idx=-1
		max_energy=10; energy_pool=10
		heal_events=[]; muzzle_events=[]
		pending_bullets=[]; salvo_charge=0; salvo_cd=0; salvo_queue=[]
		vel_x=0.0; vel_y=0.0
		hit_expl_timer=0
		dash_timer=0; dash_vx=0.0; dash_cd=0; dash_trail=[]

	func recalc_max_lives() -> void:
		var bonus := 0
		for c in loop + passives:
			if c.get("effect","") == "heal":
				var lvl = c.get("level", 1)
				if lvl == 2: bonus += 1
				elif lvl >= 3: bonus += 2
		var new_max = base_max_lives + bonus
		if new_max > max_lives:
			lives = min(lives + float(new_max - max_lives), float(new_max))
		elif new_max < max_lives:
			lives = min(lives, float(new_max))
		max_lives = new_max

	func update(fire_left:bool, fire_right:bool) -> Array:
		var bullets: Array = []
		var exploding = hit_expl_timer > 0

		# dash timers
		if dash_cd > 0: dash_cd -= 1

		# movement
		if exploding:
			facing="default"
			dash_timer = 0
		elif dash_timer > 0:
			dash_trail.append({"x": x, "y": y, "fi": fi, "t": 8})
			x += dash_vx
			facing = "left" if dash_vx < 0 else "right"
			dash_timer -= 1
			if dash_timer == 0:
				dash_cd = DASH_CD_MAX
		else:
			# Space triggers dash in held direction
			if Input.is_action_just_pressed("salvo") and dash_cd == 0:
				var dir := 0.0
				if Input.is_action_pressed("move_left"):  dir = -1.0
				elif Input.is_action_pressed("move_right"): dir = 1.0
				elif facing == "left":  dir = -1.0
				elif facing == "right": dir =  1.0
				if dir != 0.0:
					dash_timer = DASH_FRAMES; dash_vx = dir * DASH_SPEED
					invincible = max(invincible, DASH_FRAMES + 2)
			# normal movement
			if Input.is_action_pressed("move_left"):
				x -= SPEED; facing="left"
			elif Input.is_action_pressed("move_right"):
				x += SPEED; facing="right"
			else:
				facing="default"
			if Input.is_action_pressed("move_up"):
				y -= SPEED
			elif Input.is_action_pressed("move_down"):
				y += SPEED

		# fade trail
		for ghost in dash_trail: ghost["t"] -= 1
		dash_trail = dash_trail.filter(func(g): return g["t"] > 0)

		x = clamp(x, 16.0, _W-16.0)
		y = clamp(y, 16.0, _H-16.0)

		# timers
		if cooldown > 0: cooldown -= 1
		if salvo_cd  > 0: salvo_cd  -= 1

		# process salvo queue
		var nq = []
		for entry in salvo_queue:
			if entry[0] <= 0:
				for vxy in entry[1]:
					var b = BulletData.new(); b.init(x, y-20, vxy[0], vxy[1], "player")
					bullets.append(b)
			else:
				nq.append([entry[0]-1, entry[1]])
		salvo_queue = nq

		if not exploding and dash_timer == 0:
			if Input.is_action_pressed("salvo"):
				salvo_charge += 1
				if salvo_charge >= 60 and salvo_cd == 0:
					salvo_charge=0; salvo_cd=45
					var spd = 8.0
					var vecs = []
					for i in range(8):
						var a = deg_to_rad(-50.0 + i*(100.0/7.0))
						vecs.append([sin(a)*spd, -cos(a)*spd])
					for delay in [0,4,8]:
						salvo_queue.append([delay, vecs])
			else:
				salvo_charge = 0
				if fire_left and cooldown == 0:
					cooldown = SHOOT_CD
					var b = BulletData.new(); b.init(x-11, y-20, 0, -8, "player"); bullets.append(b)
				elif fire_right and cooldown == 0:
					cooldown = SHOOT_CD
					var b = BulletData.new(); b.init(x+11, y-20, 0, -8, "player"); bullets.append(b)

		# card loop
		if loop.size() > 0 and not exploding:
			loop_timer += 1
			var card = loop[loop_idx]
			if loop_timer >= effective_cycle(card):
				loop_timer = 0
				var cost = card["energy"]
				if card["effect"] == "passive":
					cost = card.get("level", 1) + 1  # 2 / 3 / 4
				elif card["effect"] == "main_shot":
					cost = -(card.get("level", 1) - 1)  # I=0  II=-1  III=-2
				if card["effect"] == "main_shot" and cost < 0 and energy_pool + cost < 0:
					# Energy starved: fall back to level I (free)
					var fallback = card.duplicate()
					fallback["level"] = 1
					_activate_card(fallback, bullets)
				elif cost >= 0 or energy_pool + cost >= 0:
					_activate_card(card, bullets)
					energy_pool = clamp(energy_pool + cost, 0, max_energy)
				loop_flash_idx = loop_idx
				loop_flash     = 18
				loop_idx = (loop_idx+1) % loop.size()
		if loop_flash > 0: loop_flash -= 1

		# passive cards tick independently
		for pc in passives:
			pc["_timer"] = pc.get("_timer", 0) + 1
			var pct = effective_cycle(pc)
			if pc["_timer"] >= pct:
				pc["_timer"] = 0
				if pc.get("effect","") == "heal":
					if lives < float(max_lives):
						var ecost = pc["energy"] as int  # -2
						if energy_pool + ecost >= 0:
							var heal_amounts = [0.2, 0.5, 1.0]
							var amount_p = heal_amounts[pc.get("level",1) - 1]
							lives = min(lives + amount_p, float(max_lives))
							heal_events.append([amount_p, false])
							energy_pool = clamp(energy_pool + ecost, 0, max_energy)
				elif pc.get("effect","") == "passive":
					var e_gain = pc.get("level",1) + 1
					energy_pool = clamp(energy_pool + e_gain, 0, max_energy)

		# pending delayed bullets
		var still = []
		for entry in pending_bullets:
			entry[0] -= 1
			if entry[0] <= 0:
				var b = BulletData.new(); b.init(x+entry[1], y+entry[2], entry[4], entry[3], "player")
				if entry.size() > 5 and entry[5] is Dictionary:
					var extra = entry[5]
					if extra.get("homing", false): b.homing = true
					if extra.has("steer"):  b.steer  = extra["steer"]
					if extra.has("bscale"): b.bscale = extra["bscale"]
				bullets.append(b)
			else:
				still.append(entry)
		pending_bullets = still

		# hit explosion animation
		if hit_expl_timer > 0:
			hit_expl_timer -= 1
			tick += 1
			if tick >= 5: tick=0; hit_expl_fi=(hit_expl_fi+1)%5

		if invincible > 0: invincible -= 1
		if hit_expl_timer == 0:
			tick += 1
			if tick >= 5: tick=0; fi=(fi+1)%2

		return bullets

	func _activate_card(card: Dictionary, bullets: Array) -> void:
		var p   = card.get("params",{})
		var cat = card["category"]
		match card["effect"]:
			"bullet":
				var b = BulletData.new(); b.init(x+p["offset_x"], y+p["offset_y"], p.get("vx",0.0), float(p["vy"]), "player"); bullets.append(b)
				muzzle_events.append({"x":x+float(p["offset_x"]),"y":y+float(p["offset_y"]),"scale":0.6,"category":cat})
			"bullet_pair":
				var ox=float(p["spread"]); var oy=float(p["offset_y"]); var vy=float(p["vy"])
				var b1=BulletData.new(); b1.init(x-ox,y+oy,0,vy,"player"); bullets.append(b1)
				var b2=BulletData.new(); b2.init(x+ox,y+oy,0,vy,"player"); bullets.append(b2)
				muzzle_events.append({"x":x-ox,"y":y+oy,"scale":0.7,"category":cat})
				muzzle_events.append({"x":x+ox,"y":y+oy,"scale":0.7,"category":cat})
			"spread":
				var count=int(p["count"]); var half=float(p["angle_deg"])/2.0
				var spd=float(p["speed"]); var oy=float(p["offset_y"])
				for i in range(count):
					var angle = -90.0 - half + i*(float(p["angle_deg"])/max(count-1,1)) if count>1 else -90.0
					var rad = deg_to_rad(angle)
					var b=BulletData.new(); b.init(x,y+oy,spd*cos(rad),spd*sin(rad),"player"); bullets.append(b)
				muzzle_events.append({"x":x,"y":y+float(p["offset_y"]),"scale":1.0,"category":cat})
			"homing":
				var count_h = 2 * card.get("level", 1) + 1   # 3 / 5 / 7
				var spd_h   = float(p["speed"])
				var oy_h    = float(p["offset_y"])
				var steer_h = float(p.get("steer", 0.06))
				var extra_h = {"homing": true, "steer": steer_h, "bscale": 2.0}
				# fire first bullet immediately, rest every 18 frames (~0.3s)
				var b0 = BulletData.new()
				b0.init(x, y+oy_h, 0.0, -spd_h, "player")
				b0.homing = true; b0.steer = steer_h; b0.bscale = 2.0
				bullets.append(b0)
				for i in range(1, count_h):
					pending_bullets.append([i * 18, 0.0, oy_h, -spd_h, 0.0, extra_h])
				muzzle_events.append({"x":x,"y":y+oy_h,"scale":0.9,"category":cat})
			"spread_front":
				var count_f = 5 + 2 * card.get("level", 1)  # 7 / 9 / 11
				var half_f  = float(p["angle_deg"]) / 2.0
				var spd_f   = float(p["speed"]); var oy_f = float(p["offset_y"])
				for i in range(count_f):
					var angle = -90.0 - half_f + i*(float(p["angle_deg"])/max(count_f-1,1)) if count_f>1 else -90.0
					var rad = deg_to_rad(angle)
					var b=BulletData.new(); b.init(x,y+oy_f,spd_f*cos(rad),spd_f*sin(rad),"player"); bullets.append(b)
				muzzle_events.append({"x":x,"y":y+oy_f,"scale":1.2+card.get("level",1)*0.1,"category":cat})
			"spread_rear":
				var count_r = 5 + 2 * card.get("level", 1)  # 7 / 9 / 11
				var half_r  = float(p["angle_deg"]) / 2.0
				var spd_r   = float(p["speed"]); var oy_r = float(p["offset_y"])
				for i in range(count_r):
					var angle = 90.0 - half_r + i * (float(p["angle_deg"]) / max(count_r-1, 1)) if count_r > 1 else 90.0
					var rad = deg_to_rad(angle)
					var b=BulletData.new(); b.init(x, y+oy_r, spd_r*cos(rad), spd_r*sin(rad), "player"); bullets.append(b)
				muzzle_events.append({"x":x,"y":y+oy_r,"scale":1.2+card.get("level",1)*0.1,"category":cat})
			"spread_sides":
				var count_s = 2 * card.get("level", 1) + 1  # 3 / 5 / 7
				var half_s  = float(p["angle_deg"]) / 2.0
				var spd_s   = float(p["speed"])
				for i in range(count_s):
					var angle_l = 180.0 - half_s + i*(float(p["angle_deg"])/max(count_s-1,1)) if count_s>1 else 180.0
					var angle_r = -half_s + i*(float(p["angle_deg"])/max(count_s-1,1)) if count_s>1 else 0.0
					var bl=BulletData.new(); bl.init(x,y,spd_s*cos(deg_to_rad(angle_l)),spd_s*sin(deg_to_rad(angle_l)),"player"); bullets.append(bl)
					var br=BulletData.new(); br.init(x,y,spd_s*cos(deg_to_rad(angle_r)),spd_s*sin(deg_to_rad(angle_r)),"player"); bullets.append(br)
				muzzle_events.append({"x":x-10,"y":y,"scale":0.9+card.get("level",1)*0.1,"category":cat})
				muzzle_events.append({"x":x+10,"y":y,"scale":0.9+card.get("level",1)*0.1,"category":cat})
			"side_bullets":
				var oy=float(p["offset_y"]); var vx=float(p["vx"]); var vy=float(p["vy"])
				var b1=BulletData.new(); b1.init(x-12,y+oy,-vx,vy,"player"); bullets.append(b1)
				var b2=BulletData.new(); b2.init(x+12,y+oy, vx,vy,"player"); bullets.append(b2)
			"heal":
				var heal_amounts = [0.2, 0.5, 1.0]
				var amount_h = heal_amounts[card.get("level", 1) - 1]
				lives = min(lives + amount_h, float(max_lives))
				heal_events.append([amount_h, false])
			"burst":
				var ox=float(p["offset_x"]); var oy=float(p["offset_y"])
				var vy=float(p["vy"]); var vx=float(p.get("vx",0))
				pending_bullets.append([p["delay"],ox,oy,vy,vx])
				var b=BulletData.new(); b.init(x+ox,y+oy,vx,vy,"player"); bullets.append(b)
			"main_shot":
				var oy_m     = float(p["offset_y"]); var vy_m = float(p["vy"])
				var count_m  = ([3, 7, 10])[card.get("level", 1) - 1]
				var interval_m = ([12, 8, 4])[card.get("level", 1) - 1]
				for side in [-11.0, 11.0]:
					var b0 = BulletData.new(); b0.init(x+side, y+oy_m, 0.0, vy_m, "player"); bullets.append(b0)
					for i in range(1, count_m):
						pending_bullets.append([i * interval_m, side, oy_m, vy_m, 0.0])
					muzzle_events.append({"x":x+side,"y":y+oy_m,"scale":0.8,"category":cat})
			"burst_column":
				var ox       = float(p["offset_x"]); var oy = float(p["offset_y"])
				var vy       = float(p["vy"]);        var vx = float(p.get("vx", 0.0))
				var interval = int(p.get("interval", 12))
				var count    = 2 * card.get("level", 1) + 1   # 3 / 5 / 7
				var b0 = BulletData.new(); b0.init(x+ox, y+oy, vx, vy, "player"); bullets.append(b0)
				for i in range(1, count):
					pending_bullets.append([i * interval, ox, oy, vy, vx])
				muzzle_events.append({"x":x+ox,"y":y+oy,"scale":0.8,"category":cat})
			"passive":
				pass  # energy handled in caller

	func hit() -> bool:
		if invincible == 0:
			lives -= 1
			invincible      = 90
			hit_expl_timer  = 25
			hit_expl_x      = x; hit_expl_y = y; hit_expl_fi = 0
			salvo_charge    = 0; salvo_queue = []
			return true
		return false

	func rect() -> Rect2:
		return Rect2(x-10, y-10, 20, 20)

	func collect_rect() -> Rect2:
		return Rect2(x-15, y-15, 30, 30)

	static func effective_cycle(card: Dictionary) -> int:
		var base := card["cycle_time"] as int
		var lvl  := card.get("level", 1) as int
		if lvl == 1: return int(base * 0.8)
		if lvl == 2: return int(base * 0.6)
		if lvl == 3: return int(base * 0.5)
		return base

	func energy_net() -> int:
		var total = loop.reduce(func(a, c):
			var e = c["energy"]
			if c["effect"] == "passive": e = c.get("level", 1) + 1
			elif c["effect"] == "main_shot": e = -(c.get("level", 1) - 1)
			return a + e
		, 0)
		for p in passives:
			if p.get("effect","") == "passive": total += p.get("level",1) + 1
		return total

	func is_starved() -> bool:
		if loop.is_empty(): return false
		var card = loop[loop_idx]
		if card["effect"] == "main_shot": return false  # always fires at minimum level I
		return card["energy"] < 0 and energy_pool + card["energy"] < 0

# ── Inner class: ExplosionData ────────────────────────────────────────────────
class ExplosionData:
	var x: float; var y: float
	var tick := 0; var fi := 0; var done := false

	func init(px:float,py:float) -> void: x=px; y=py

	func update() -> void:
		tick += 1
		if tick >= 5: tick=0; fi+=1
		if fi >= 5: done=true

# ── Inner class: BossData ─────────────────────────────────────────────────────
class BossData:
	const W_CONST    := 480
	const H_CONST    := 640
	const MAX_HP     := 450
	const SINE_P     := {1:[120.0,0.008],2:[150.0,0.014],3:[150.0,0.020]}
	const SPREAD_INT := {1:60,2:47,3:33}
	const AIMED_INT  := 40
	const RING_INT   := 80
	const BSPD       := 4.8

	var x          := float(W_CONST)/2.0
	var y          := float(96/2+20)
	var hp         := MAX_HP
	var phase      := 1
	var sine_t     := 0.0
	var fi         := 0
	var anim_tick  := 0
	var spread_t   := 0
	var aimed_t    := 0
	var ring_t     := 0
	var minion_t   := 0
	var lunge_dy   := 0.0
	var lunge_t    := 0
	var lunge_cd   := 0
	var alive      := true
	var flash_t    := 0
	var freeze_t   := 0
	var pending_blasts: Array = []  # [[frames_left,ox,oy],...]

	func _phase_of() -> int:
		if hp > 300: return 1
		if hp > 150: return 2
		return 3

	func hit() -> void:
		if not alive: return
		hp -= 1
		var np = _phase_of()
		if np != phase:
			phase    = np
			flash_t  = 20
			for i in range(6):
				var angle = randf() * TAU
				var dist  = randi_range(5,35)
				pending_blasts.append([i*30, int(cos(angle)*dist), int(sin(angle)*dist)])
			freeze_t = 5*30+1

	func update(px:float, py:float, out_bullets:Array, out_blasts:Array) -> void:
		# pending blasts
		var sb = []
		for entry in pending_blasts:
			entry[0] -= 1
			if entry[0] <= 0: out_blasts.append([entry[1],entry[2]])
			else: sb.append(entry)
		pending_blasts = sb

		if freeze_t > 0:
			freeze_t -= 1
			if freeze_t == 0:
				var amp_f  = SINE_P[_phase_of()][0]
				var freq_f = SINE_P[_phase_of()][1]
				var val    = clamp((x - W_CONST/2.0) / amp_f, -1.0, 1.0)
				sine_t     = asin(val) / freq_f - 1.0

		phase = _phase_of()

		# movement
		if freeze_t == 0:
			var amp  = SINE_P[phase][0]
			var freq = SINE_P[phase][1]
			sine_t += 1
			x = W_CONST/2.0 + amp * sin(sine_t * freq)

		if phase >= 2 and freeze_t == 0:
			if lunge_cd > 0: lunge_cd -= 1
			elif lunge_t <= 0:
				lunge_t  = 30
				lunge_dy = 2.5 if py > y else -2.5
				lunge_cd = 180
			if lunge_t > 0: y += lunge_dy; lunge_t -= 1; if lunge_t==0: lunge_dy=0.0

		y = clamp(y, 58.0, float(H_CONST)/3.0)

		anim_tick += 1
		if anim_tick >= 5: anim_tick=0; fi=(fi+1)%2
		if flash_t > 0: flash_t -= 1

		# spread shot
		spread_t += 1
		if spread_t >= SPREAD_INT[phase]:
			spread_t = 0
			for i in range(6):
				var a = deg_to_rad(-60.0 + i*24.0)
				var b = BulletData.new(); b.init(x, y+48, sin(a)*BSPD, cos(a)*BSPD, "enemy")
				out_bullets.append(b)

		# aimed shot
		if phase >= 2:
			aimed_t += 1
			if aimed_t >= AIMED_INT:
				aimed_t = 0
				var dx = px-x; var dy = py-y
				var dist = max(sqrt(dx*dx+dy*dy), 1.0)
				var b = BulletData.new(); b.init(x,y,(dx/dist)*BSPD,(dy/dist)*BSPD,"enemy")
				out_bullets.append(b)

		# ring burst
		if phase >= 3:
			ring_t += 1
			if ring_t >= RING_INT:
				ring_t = 0
				for i in range(8):
					var a = deg_to_rad(float(i)*45.0)
					var b = BulletData.new(); b.init(x,y,cos(a)*BSPD,sin(a)*BSPD,"enemy")
					out_bullets.append(b)

	func rect() -> Rect2:
		return Rect2(x-48, y-48, 96, 96)

# ── Inner class: CardDropData ─────────────────────────────────────────────────
class CardDropData:
	const W_D      := 14.0
	const H_D      := 18.0
	const SPD      := 1.8
	const FRICTION := 0.94   # vx damping per frame
	const MAX_VX   := 2.0
	const MAX_TILT := 0.35

	var x        : float
	var y        : float
	var vx       : float = 0.0
	var rotation : float = 0.0
	var card     : Dictionary

	func init(px:float, py:float, c:Dictionary) -> void:
		x = px; y = py; card = c

	func update() -> void:
		vx *= FRICTION
		x = clamp(x + vx, W_D, H - W_D)
		y += SPD
		rotation = clamp(vx * 0.15, -MAX_TILT, MAX_TILT)

	func nudge() -> void:
		vx = clamp(vx + randf_range(-0.8, 0.8), -MAX_VX, MAX_VX)

	func off_screen() -> bool: return y - H_D > H

	func rect() -> Rect2:
		return Rect2(x - W_D/2, y - H_D/2, W_D, H_D)

# ─────────────────────────────────────────────────────────────────────────────
# _ready / setup
# ─────────────────────────────────────────────────────────────────────────────
func _ready() -> void:
	_load_sprites()
	_setup_audio()
	var music = get_node("../AudioStreamPlayer") as AudioStreamPlayer
	if music: music.stream_paused = true
	_font = load("res://Fonts/PressStart2P-Regular.ttf") as FontFile
	for d in CARD_DATA:
		if d.get("droppable",false): _droppable_cards.append(d)
	randomize()
	var rng = RandomNumberGenerator.new(); rng.seed = 42
	for i in range(120):
		_stars.append({"x": rng.randf_range(0, W), "y": rng.randf_range(0, H),
			"r": rng.randf_range(0.5, 1.5), "b": rng.randf_range(0.4, 1.0)})

func _load_sprites() -> void:
	var ship_t = load("res://Player/ship.png") as Texture2D
	_spr["ship_default"] = [_atl(ship_t,16,24,2,0),_atl(ship_t,16,24,2,1)]
	_spr["ship_left"]    = [_atl(ship_t,16,24,0,0),_atl(ship_t,16,24,0,1)]
	_spr["ship_right"]   = [_atl(ship_t,16,24,4,0),_atl(ship_t,16,24,4,1)]

	var ebig_t = load("res://Enemies/enemy-big.png") as Texture2D
	_spr["e_big"] = [_atl(ebig_t,32,32,0,0),_atl(ebig_t,32,32,1,0)]

	var emed_t = load("res://Enemies/enemy-medium.png") as Texture2D
	_spr["e_med"] = [_atl(emed_t,16,16,0,0),_atl(emed_t,16,16,1,0),
					 _atl(emed_t,16,16,2,0),_atl(emed_t,16,16,3,0)]

	var esml_t = load("res://Enemies/enemy-small.png") as Texture2D
	_spr["e_sml"] = [_atl(esml_t,16,16,0,0),_atl(esml_t,16,16,1,0)]

	var bolt_t = load("res://Bullet/laser-bolts.png") as Texture2D
	_spr["bolt_player"] = [_atl(bolt_t,16,16,0,1),_atl(bolt_t,16,16,1,1)]
	_spr["bolt_enemy"]  = [_atl(bolt_t,16,16,0,0),_atl(bolt_t,16,16,1,0)]

	var expl_t = load("res://MIsc/explosion.png") as Texture2D
	_spr["expl"] = [_atl(expl_t,16,16,0,0),_atl(expl_t,16,16,1,0),
					_atl(expl_t,16,16,2,0),_atl(expl_t,16,16,3,0),_atl(expl_t,16,16,4,0)]

	# boss uses e_big frames
	_spr["boss"] = _spr["e_big"]

func _atl(tex:Texture2D,fw:int,fh:int,col:int,row:int) -> AtlasTexture:
	var a := AtlasTexture.new()
	a.atlas  = tex
	a.region = Rect2(col*fw, row*fh, fw, fh)
	return a

func _setup_audio() -> void:
	_snd_pshoot = $"../AudioPlayers/PlayerShoot"
	_snd_expl   = $"../AudioPlayers/Explosion"
	_snd_wave   = $"../AudioPlayers/WaveStart"

# ─────────────────────────────────────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────────────────────────────────────
func _make_card(id:String) -> Dictionary:
	for d in CARD_DATA:
		if d["id"] == id:
			var c = d.duplicate()
			c["level"] = 1
			return c
	return {}

func _random_card() -> Dictionary:
	var roll := randi() % 100
	var category := "shoot" if roll < 50 else ("heal" if roll < 75 else "energy")
	var pool := _droppable_cards.filter(func(d): return d["category"] == category)
	if pool.is_empty(): pool = _droppable_cards
	var c = pool[randi() % pool.size()].duplicate()
	if not c.has("level"): c["level"] = 1
	return c

func _generate_card_drop_queue() -> void:
	var shoot_ids = ["main_shot","spread_shot","rapid_shot","side_spread"]
	# collect unique shoot ids the player already owns
	var owned_shoot: Array = []
	for c in _player.loop:
		if c["category"] == "shoot" and not owned_shoot.has(c["id"]):
			owned_shoot.append(c["id"])
	# pick 3 distinct shoot cards — at least 1 must be owned
	var picks: Array = []
	if not owned_shoot.is_empty():
		var owned_shuf = owned_shoot.duplicate(); owned_shuf.shuffle()
		picks.append(owned_shuf[0])
	var remaining = shoot_ids.filter(func(id): return not picks.has(id))
	remaining.shuffle()
	for id in remaining:
		if picks.size() >= 3: break
		picks.append(id)
	picks.shuffle()
	# build queue: 2 shoot (owned preferred + 1 other) + 1 heal + 1 energy + 1 shoot, shuffled
	var queue = [_make_card(picks[0]), _make_card(picks[1] if picks.size() > 1 else picks[0]), _make_card("heal"), _make_card("energy_cell"), _make_card(picks[2] if picks.size() > 2 else picks[0])]
	queue.shuffle()
	_card_drop_queue = queue

func _starting_loop() -> Array:
	return [_make_card("main_shot")]

func _make_fleet(wave_idx:int, keep_fraction:float=0.75) -> FleetData:
	var cfg = WAVE_CONFIGS[wave_idx].duplicate(true)
	var keep = int(round(cfg["enemies"].size() * keep_fraction))
	cfg["enemies"] = cfg["enemies"].slice(0, keep)
	var fl = FleetData.new()
	fl.setup(cfg)
	var wave_hp = WAVE_HP[clamp(wave_idx, 0, WAVE_HP.size()-1)]
	for e in fl.enemies: e.hp = wave_hp
	for i in fl.enemies.size():
		if i in _wave_carrier_slots:
			fl.enemies[i].carries_card = true
	return fl

func _assign_charger(fleet: FleetData) -> void:
	var candidates = fleet.alive_enemies()
	if candidates.is_empty(): return
	candidates[randi() % candidates.size()].charging = true

func _play(snd:AudioStreamPlayer) -> void:
	if not _muted: snd.play()

# ─────────────────────────────────────────────────────────────────────────────
# Game start / wave launch
# ─────────────────────────────────────────────────────────────────────────────
func _start_game() -> void:
	_player = PlayerData.new(); _player.init()
	_player.loop = _starting_loop(); _player.recalc_max_lives()
	_fleet=null; _boss=null; _boss_minions=null
	_boss_timer=0; _boss_dq=[]
	_pbullets=[]; _ebullets=[]; _expls=[]; _cdrops=[]; _collected=[]
	_score=0; _wave=0; _wave_timer=WAVE_INTRO_DUR
	_generate_card_drop_queue()
	_evo_kills=0; _evo_ready=false; _evo_flash_timer=0
	_cforge_cursor=0; _cforge_sel1=-1; _cforge_flash_timer=0; _cforge_result_idx=0; _cforge_result={}; _cforge_msg=""

func _launch_wave() -> void:
	var keep = int(round(WAVE_CONFIGS[_wave]["enemies"].size() * 0.75))
	var idx_pool : Array = []
	for i in keep: idx_pool.append(i)
	idx_pool.shuffle()
	_wave_carrier_slots = idx_pool.slice(0, min(CARRIER_COUNT, idx_pool.size()))
	_fleet    = _make_fleet(_wave, 0.75)
	_pbullets=[]; _ebullets=[]; _expls=[]; _cdrops=[]; _collected=[]
	_kills_this_spawn = 0; _respawns_no_kill = 0
	_generate_card_drop_queue()
	_play(_snd_wave)

# ─────────────────────────────────────────────────────────────────────────────
# Input
# ─────────────────────────────────────────────────────────────────────────────
var _fire_left  := false
var _fire_right := false

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var k = event.keycode
		if k == KEY_M:
			_muted = not _muted
			var music = get_node("../AudioStreamPlayer") as AudioStreamPlayer
			if music: music.stream_paused = _muted
			return

		match _st:
			GS.MENU:
				if k == KEY_UP or k == KEY_DOWN: _menu_sel = 1 - _menu_sel
				elif k == KEY_ENTER or k == KEY_SPACE:
					if _menu_sel == 0: _start_game(); _st=GS.WAVE_INTRO
					else: get_tree().quit()
			GS.WAVE_INTRO:
				if k == KEY_ESCAPE: _prev_st=_st; _pause_sel=0; _st=GS.PAUSED
				elif k == KEY_SPACE: _wave_timer=0
			GS.PLAYING:
				if k == KEY_ESCAPE: _prev_st=_st; _pause_sel=0; _st=GS.PAUSED
				elif k == KEY_I: _arr_cursor=0; _arr_held=null; _arr_from_playing=true; _st=GS.CARD_ARRANGE
				elif k == KEY_Z: _fire_left=true
				elif k == KEY_X: _fire_right=true
				elif k == KEY_B:
					_fleet=null; _pbullets=[]; _ebullets=[]; _expls=[]; _cdrops=[]
					_boss=BossData.new(); _boss_timer=WAVE_INTRO_DUR; _st=GS.BOSS_INTRO
			GS.BOSS:
				if k == KEY_ESCAPE: _prev_st=_st; _pause_sel=0; _st=GS.PAUSED
				elif k == KEY_Z: _fire_left=true
				elif k == KEY_X: _fire_right=true
			GS.BOSS_INTRO:
				if k == KEY_ESCAPE: _prev_st=_st; _pause_sel=0; _st=GS.PAUSED
			GS.PAUSED:
				if k == KEY_ESCAPE: _st=_prev_st
				elif k == KEY_UP or k == KEY_DOWN: _pause_sel = 1 - _pause_sel
				elif k == KEY_ENTER or k == KEY_SPACE:
					if _pause_sel==0: _st=_prev_st
					else: _menu_sel=0; _st=GS.MENU
			GS.CARD_SELECT:  # legacy — redirect to merged screen
				_arr_focus = 0 if _collected.size() > 0 else 1
				_st = GS.CARD_ARRANGE
			GS.CARD_FORGE:
				if _cforge_flash_timer > 0:
					pass  # block input during blink
				elif k == KEY_ESCAPE:
					_cforge_sel1=-1; _cforge_msg=""
					_st = GS.CARD_ARRANGE
				elif k == KEY_LEFT:
					if _player.loop.size() > 0:
						_cforge_cursor = (_cforge_cursor-1+_player.loop.size()) % _player.loop.size()
				elif k == KEY_RIGHT:
					if _player.loop.size() > 0:
						_cforge_cursor = (_cforge_cursor+1) % _player.loop.size()
				elif k == KEY_SPACE:
					if _player.loop.size() >= 2:
						if _cforge_sel1 == -1:
							_cforge_sel1 = _cforge_cursor
							_cforge_msg = "NOW SELECT CARD TO MERGE WITH"
						else:
							if _cforge_cursor == _cforge_sel1:
								_cforge_msg = "PICK A DIFFERENT CARD"
							else:
								var c1 = _player.loop[_cforge_sel1]
								var c2 = _player.loop[_cforge_cursor]
								if c1["id"] != c2["id"]:
									_cforge_msg = "CARDS MUST MATCH"
								elif max(c1.get("level",1), c2.get("level",1)) >= 3:
									_cforge_msg = "ALREADY MAX LEVEL"
								else:
									var new_lvl = max(c1.get("level",1), c2.get("level",1)) + 1
									var fused = c1.duplicate(); fused["level"] = new_lvl
									var i1 = _cforge_sel1; var i2 = _cforge_cursor
									if i1 < i2:
										_player.loop.remove_at(i2); _player.loop.remove_at(i1)
									else:
										_player.loop.remove_at(i1); _player.loop.remove_at(i2)
									var insert_at = min(i1,i2)
									_player.loop.insert(insert_at, fused); _player.recalc_max_lives()
									if _player.loop_idx >= _player.loop.size():
										_player.loop_idx = max(_player.loop.size()-1,0); _player.loop_timer=0
									_cforge_result = fused
									_cforge_result_idx = insert_at
									_cforge_flash_timer = 60
									_cforge_sel1=-1; _cforge_msg=""
			GS.CARD_ARRANGE:
				if k == KEY_I or (k == KEY_ESCAPE and _arr_from_playing):
					_arr_held=null; _arr_from_playing=false; _st=GS.PLAYING; return
				if _arr_focus == 0 and _collected.size() > 0:
					# ── Card pick section ──
					if k == KEY_UP:
						_csel_cursor = (_csel_cursor - 1 + _collected.size()) % _collected.size()
					elif k == KEY_DOWN:
						_csel_cursor = (_csel_cursor + 1) % _collected.size()
					elif k == KEY_TAB:
						_arr_focus = 1
					elif k == KEY_SPACE:
						var sel_card = _collected[_csel_cursor]
						var is_passive = sel_card["category"] in ["heal","energy"]
						var sel_level  = sel_card.get("level", 1)
						_collected.clear(); _csel_chosen=[]; _arr_held=null
						_card_op_msg = ""
						_cforge_cursor=0; _cforge_sel1=-1; _cforge_flash_timer=0; _cforge_result_idx=0; _cforge_result={}; _cforge_msg=""
						if sel_level > 1:
							var _upg_done := false
							for i in range(_player.loop.size()):
								if _player.loop[i]["id"] == sel_card["id"]:
									_player.loop[i] = sel_card; _player.recalc_max_lives()
									_upg_done = true; break
							if not _upg_done:
								for i in range(_player.passives.size()):
									if _player.passives[i]["id"] == sel_card["id"]:
										var up = sel_card.duplicate(); up.erase("_timer")
										_player.passives[i] = up; _player.recalc_max_lives(); break
						elif is_passive:
							if _player.passives.size() < 2:
								_player.passives.append(sel_card); _player.recalc_max_lives()
							else:
								var match_idx = -1
								for i in range(_player.passives.size()):
									if _player.passives[i]["category"] == sel_card["category"]:
										match_idx = i; break
								if match_idx >= 0:
									var old = _player.passives[match_idx]
									var new_lvl = min(max(old.get("level",1), sel_card.get("level",1)) + 1, 3)
									var fused = old.duplicate(); fused["level"] = new_lvl; fused.erase("_timer")
									_player.passives[match_idx] = fused; _player.recalc_max_lives()
									_cforge_result = fused; _cforge_result_idx = -1; _cforge_flash_timer = 60
						elif _player.loop.size() >= _player.MAX_LOOP:
							_replace_card = sel_card; _replace_cursor = 0
							_st = GS.CARD_REPLACE
						else:
							_player.loop.append(sel_card); _player.recalc_max_lives()
						_arr_focus = 1; _arr_cursor = 0
				else:
					# ── Loop arrange section ──
					var _slot_count = _player.loop.size() + 1  # +1 for NEXT WAVE / CLOSE
					if k == KEY_TAB and _collected.size() > 0:
						_arr_focus = 0
					elif k == KEY_LEFT:
						if _arr_held != null:
							if _arr_held > 0:
								var tmp=_player.loop[_arr_held]; _player.loop[_arr_held]=_player.loop[_arr_held-1]; _player.loop[_arr_held-1]=tmp
								if _player.loop_idx == _arr_held: _player.loop_idx -= 1
								elif _player.loop_idx == _arr_held - 1: _player.loop_idx += 1
								_arr_held-=1; _arr_cursor=_arr_held
						else:
							_arr_cursor = (_arr_cursor-1+_slot_count) % _slot_count
					elif k == KEY_RIGHT:
						if _arr_held != null:
							if _arr_held < _player.loop.size()-1:
								var tmp=_player.loop[_arr_held]; _player.loop[_arr_held]=_player.loop[_arr_held+1]; _player.loop[_arr_held+1]=tmp
								if _player.loop_idx == _arr_held: _player.loop_idx += 1
								elif _player.loop_idx == _arr_held + 1: _player.loop_idx -= 1
								_arr_held+=1; _arr_cursor=_arr_held
						else:
							_arr_cursor = (_arr_cursor+1) % _slot_count
					elif k == KEY_SPACE:
						var on_next_wave = (_arr_cursor == _player.loop.size())
						if on_next_wave and _arr_held == null:
							_arr_held=null
							if _arr_from_playing:
								_arr_from_playing=false; _st=GS.PLAYING
							else:
								_evo_ready=false; _evo_kills=0
								if _wave < WAVE_CONFIGS.size()-1:
									_wave+=1; _wave_timer=WAVE_INTRO_DUR; _st=GS.WAVE_INTRO
								else:
									_boss=BossData.new(); _boss_timer=WAVE_INTRO_DUR; _st=GS.BOSS_INTRO
						else:
							if _arr_held == null and not on_next_wave:
								_arr_held = _arr_cursor
							else:
								_arr_held = null
					elif k==KEY_Z:
						if _arr_held==null and _player.loop.size() > 0 and _arr_cursor < _player.loop.size():
							_player.loop.remove_at(_arr_cursor); _player.recalc_max_lives()
							if _player.loop_idx >= _player.loop.size():
								_player.loop_idx = max(_player.loop.size()-1, 0); _player.loop_timer = 0
							_arr_cursor = clamp(_arr_cursor, 0, _player.loop.size())
			GS.CARD_REPLACE:
				if k == KEY_LEFT:
					_replace_cursor = (_replace_cursor - 1 + _player.loop.size()) % _player.loop.size()
				elif k == KEY_RIGHT:
					_replace_cursor = (_replace_cursor + 1) % _player.loop.size()
				elif k == KEY_SPACE:
					_player.loop[_replace_cursor] = _replace_card
					_player.recalc_max_lives()
					if _player.loop_idx >= _player.loop.size():
						_player.loop_idx = 0; _player.loop_timer = 0
					_replace_card = {}; _arr_cursor = 0; _arr_held = null
					_st = GS.CARD_ARRANGE
			GS.CARD_OP:
				if k == KEY_ESCAPE:
					_collected.insert(clamp(_csel_cursor, 0, _collected.size()), _card_op_card)
					_card_op_msg = ""; _arr_focus = 0; _st = GS.CARD_ARRANGE
				elif k == KEY_LEFT:
					if _player.loop.size() > 0:
						_card_op_cursor = (_card_op_cursor-1+_player.loop.size()) % _player.loop.size()
				elif k == KEY_RIGHT:
					if _player.loop.size() > 0:
						_card_op_cursor = (_card_op_cursor+1) % _player.loop.size()
				elif k == KEY_X:
					_execute_card_op()
			GS.GAME_OVER, GS.WIN:
				if k == KEY_R: _menu_sel=0; _st=GS.MENU

# ─────────────────────────────────────────────────────────────────────────────
# Process
# ─────────────────────────────────────────────────────────────────────────────
func _process(_delta: float) -> void:
	_update_state()
	_fire_left=false; _fire_right=false
	if _shake > 0: _shake -= 1
	for ft in _float_texts: ft["y"] -= 1.8; ft["timer"] -= 1
	_float_texts = _float_texts.filter(func(ft): return ft["timer"] > 0)
	for mf in _muzzle_flashes: mf["timer"] -= 1
	_muzzle_flashes = _muzzle_flashes.filter(func(mf): return mf["timer"] > 0)
	if _ship_flash_timer > 0: _ship_flash_timer -= 1
	queue_redraw()

func _update_state() -> void:
	match _st:
		GS.WAVE_INTRO:
			if _player: _player.update(false,false)
			_wave_timer -= 1
			if _wave_timer <= 0: _launch_wave(); _st=GS.PLAYING
		GS.PLAYING:
			_update_playing()
		GS.BOSS_INTRO:
			if _player: _player.update(false,false)
			_boss_timer -= 1
			if _boss_timer <= 0:
				_pbullets=[]; _ebullets=[]; _expls=[]
				_play(_snd_wave); _st=GS.BOSS
		GS.BOSS:
			_update_boss()
		GS.BOSS_DEATH:
			_update_boss_death()
		GS.CARD_FORGE:
			if _cforge_flash_timer > 0:
				_cforge_flash_timer -= 1
				if _cforge_flash_timer <= 0:
					_st = GS.CARD_ARRANGE
		GS.EVO_FLASH:
			_evo_flash_timer -= 1
			if _evo_flash_timer <= 0:
				_evo_ready = true
				_evo_kills = 0
				_fleet = null
				_csel_cursor=0; _csel_chosen=[]
				_auto_upgrade_collected()
				_arr_cursor=0; _arr_held=null; _arr_from_playing=false
				_arr_focus = 0 if _collected.size() > 0 else 1
				_st = GS.CARD_ARRANGE
		_:
			pass  # menu, paused, card screens, game_over, win handled by input

func _consume_muzzle_events() -> void:
	for ev in _player.muzzle_events:
		var col = CARD_COLORS.get(ev["category"], WHITE)
		_muzzle_flashes.append({"x":ev["x"],"y":ev["y"],"scale":ev["scale"],
			"color":col,"timer":5,"total":5})
		if _ship_flash_timer == 0:
			_ship_flash_timer = 4
			_ship_flash_col   = col
	_player.muzzle_events.clear()

func _consume_heal_events() -> void:
	for ev in _player.heal_events:
		var amount   = ev[0]; var gave_max = ev[1]
		var dur      = 36  # 0.6s at 60fps
		var px       = _player.x; var py = _player.y - 30.0
		_float_texts.append({"x":px,"y":py,"text":"+%d"%amount,
			"color":Color(0.2,0.9,0.3),"timer":dur,"total":dur,"size":16})
		if gave_max:
			_float_texts.append({"x":px,"y":py-20.0,"text":"+1 MAX HEALTH",
				"color":Color(0.863,0.118,0.118),"timer":dur,"total":dur,"size":8})
	_player.heal_events.clear()

func _evo_kill_target() -> int:
	if _wave < 3: return 25
	if _wave < 6: return 30
	return 35

func _register_kill() -> void:
	_kills_this_spawn += 1
	for cd in _cdrops: cd.nudge()
	if _evo_ready or _evo_flash_timer > 0: return
	_evo_kills = min(_evo_kills + 1, _evo_kill_target())
	_check_evo_trigger()

func _check_evo_trigger() -> void:
	if _evo_ready or _evo_flash_timer > 0: return
	if _collected.size() >= EVO_CARDS and _evo_kills >= _evo_kill_target():
		_evo_flash_timer = 120
		_st = GS.EVO_FLASH

func _steer_homing_bullets(targets: Array) -> void:
	for b in _pbullets:
		if not b.homing: continue
		# prefer nearest enemy above the bullet
		var best_d2 := INF
		var near_x  : float = b.x; var near_y : float = b.y - 10.0
		var found := false
		for t in targets:
			if t.y >= b.y: continue  # skip enemies below bullet
			var dx = t.x - b.x; var dy = t.y - b.y
			var d2 = dx*dx + dy*dy
			if d2 < best_d2:
				best_d2 = d2; near_x = t.x; near_y = t.y; found = true
		if not found:  # fallback: nearest overall
			best_d2 = INF
			for t in targets:
				var dx = t.x - b.x; var dy = t.y - b.y
				var d2 = dx*dx + dy*dy
				if d2 < best_d2:
					best_d2 = d2; near_x = t.x; near_y = t.y; found = true
		if not found: continue
		var dx = near_x - b.x; var dy = near_y - b.y
		var dist = sqrt(dx*dx + dy*dy)
		if dist < 1.0: continue
		var spd = max(sqrt(b.vx*b.vx + b.vy*b.vy), 7.0)  # enforce min speed
		b.vx = lerp(b.vx, dx/dist * spd, 0.15)
		b.vy = lerp(b.vy, dy/dist * spd, 0.15)
		if b.vy > -1.0: b.vy = -1.0  # always keep some upward momentum

func _update_bullets_and_expls() -> void:
	for b in _pbullets: b.update()
	for b in _ebullets: b.update()
	for e in _expls:    e.update()
	_pbullets = _pbullets.filter(func(b): return not b.off_screen())
	_ebullets = _ebullets.filter(func(b): return not b.off_screen())
	_expls    = _expls.filter(func(e): return not e.done)

func _update_playing() -> void:
	var fired = _player.update(_fire_left, _fire_right)
	for b in fired: _pbullets.append(b); _play(_snd_pshoot)
	_consume_muzzle_events()
	_consume_heal_events()

	_steer_homing_bullets(_fleet.alive_enemies())
	_update_bullets_and_expls()

	var enemy_shots: Array = []
	_fleet.update(enemy_shots)
	if not enemy_shots.is_empty():
		for b in enemy_shots: _ebullets.append(b)

	const CHARGE_SPEED := 4.0
	for e in _fleet.alive_enemies():
		if e.charging:
			var dx = _player.x - e.x
			var dy = _player.y - e.y
			var dist = sqrt(dx * dx + dy * dy)
			if dist > 0:
				e.x += dx / dist * CHARGE_SPEED
				e.y += dy / dist * CHARGE_SPEED

	# player bullets vs enemies
	var alive_e = _fleet.alive_enemies()
	for b in _pbullets.duplicate():
		for e in alive_e:
			if not e.alive: continue
			if b.hit_rect().intersects(e.rect()):
				_pbullets.erase(b)
				if e.hit(2 if b.homing else 1):
					_score += 10
					_expls.append(_make_expl(e.x,e.y))
					_play(_snd_expl)
					if e.carries_card and _collected.size() < EVO_CARDS: _cdrops.append(_make_cdrop(e.x,e.y))
					_register_kill()
				break


	# enemy bullets vs player
	if _player.invincible == 0:
		for b in _ebullets.duplicate():
			if b.rect().intersects(_player.rect()):
				_ebullets.erase(b)
				if _player.hit(): _shake=20

	# player body vs enemy body
	if _player.invincible == 0:
		for e in _fleet.alive_enemies():
			if e.rect().intersects(_player.rect()):
				e.alive=false
				_expls.append(_make_expl(e.x,e.y)); _play(_snd_expl)
				if _player.hit(): _shake=20

	# card drops
	for cd in _cdrops: cd.update()
	for cd in _cdrops.duplicate():
		if cd.rect().intersects(_player.collect_rect()) and _collected.size() < EVO_CARDS:
			_cdrops.erase(cd); _collected.append(cd.card)
			_check_evo_trigger()
	_cdrops = _cdrops.filter(func(cd): return not cd.off_screen())

	# enemies reaching bottom
	for e in _fleet.alive_enemies():
		if e.y + 16 >= H: e.alive=false

	# respawn fleet when cleared, or merge new wave when old is in lower 15%
	var alive_e2 = _fleet.alive_enemies()
	if alive_e2.is_empty():
		if _kills_this_spawn == 0: _respawns_no_kill += 1
		else: _respawns_no_kill = 0
		_kills_this_spawn = 0
		_fleet = _make_fleet(_wave, 0.75)
		if _respawns_no_kill >= 3: _assign_charger(_fleet)
	elif alive_e2.all(func(e): return e.y >= H * 0.75):
		if _kills_this_spawn == 0: _respawns_no_kill += 1
		else: _respawns_no_kill = 0
		_kills_this_spawn = 0
		var new_fleet = _make_fleet(_wave, 0.75)
		if _respawns_no_kill >= 3: _assign_charger(new_fleet)
		_fleet.enemies.append_array(new_fleet.enemies)

	if _player.lives <= 0:
		_st=GS.GAME_OVER

func _update_boss() -> void:
	var fired = _player.update(_fire_left, _fire_right)
	for b in fired: _pbullets.append(b); _play(_snd_pshoot)
	_consume_muzzle_events()
	_consume_heal_events()

	var homing_targets: Array = [_boss]
	if _boss_minions: homing_targets.append_array(_boss_minions.alive_enemies())
	_steer_homing_bullets(homing_targets)
	_update_bullets_and_expls()

	# boss minions
	if _boss_minions:
		var mshots: Array = []
		_boss_minions.update(mshots)
		for b in mshots: _ebullets.append(b)
		for e in _boss_minions.alive_enemies():
			if e.y+16 >= H: e.alive=false
		if _boss_minions.alive_enemies().is_empty(): _boss_minions=null

	# boss update
	var bshots: Array=[]; var bblasts: Array=[]
	_boss.update(_player.x, _player.y, bshots, bblasts)
	for b in bshots: _ebullets.append(b)
	for bl in bblasts:
		_expls.append(_make_expl(_boss.x+bl[0], _boss.y+bl[1])); _play(_snd_expl)

	# minion spawning throughout boss fight
	if _boss_minions == null:
		_boss.minion_t += 1
		if _boss.minion_t >= 480:
			_boss.minion_t=0
			var wi = randi() % WAVE_CONFIGS.size()
			_boss_minions = _make_fleet(wi, 0.5)

	# player bullets vs boss
	for b in _pbullets.duplicate():
		if b.rect().intersects(_boss.rect()):
			_pbullets.erase(b); _score+=50; _boss.hit(); _play(_snd_expl); break

	# player bullets vs boss minions
	if _boss_minions:
		var malive = _boss_minions.alive_enemies()
		for b in _pbullets.duplicate():
			for e in malive:
				if b.hit_rect().intersects(e.rect()):
					_pbullets.erase(b)
					if e.hit(2 if b.homing else 1): _score+=10; _expls.append(_make_expl(e.x,e.y)); _play(_snd_expl)
					break


	# enemy bullets vs player
	if _player.invincible == 0:
		for b in _ebullets.duplicate():
			if b.rect().intersects(_player.rect()):
				_ebullets.erase(b)
				if _player.hit(): _shake=20

	# boss body vs player
	if _player.invincible == 0 and _boss.rect().intersects(_player.rect()):
		if _player.hit(): _shake=20

	# boss minions vs player
	if _player.invincible == 0 and _boss_minions:
		for e in _boss_minions.alive_enemies():
			if e.rect().intersects(_player.rect()):
				e.alive=false; _expls.append(_make_expl(e.x,e.y)); _play(_snd_expl)
				if _player.hit(): _shake=20

	# boss death
	if _boss.hp <= 0 and _boss.alive:
		_boss.alive=false
		var t=0
		var mlist = _boss_minions.alive_enemies() if _boss_minions else []
		for i in range(22):
			var bx=randi_range(48, W-48); var by=randi_range(48, H-48)
			var enemies_for_exp: Array=[]
			if i >= 4 and i <= 17 and not mlist.is_empty():
				enemies_for_exp.append(mlist[randi()%mlist.size()])
			_boss_dq.append([t,float(bx),float(by),enemies_for_exp])
			t += randi_range(12,30)
		_st=GS.BOSS_DEATH

	if _player.lives <= 0: _st=GS.GAME_OVER

func _update_boss_death() -> void:
	for e in _expls: e.update()
	_expls = _expls.filter(func(ex): return not ex.done)
	var still: Array=[]
	for entry in _boss_dq:
		entry[0] -= 1
		if entry[0] <= 0:
			_expls.append(_make_expl(entry[1],entry[2])); _play(_snd_expl)
			for e in entry[3]: e.alive=false; _expls.append(_make_expl(e.x,e.y))
		else: still.append(entry)
	_boss_dq=still
	if _boss_dq.is_empty() and _expls.is_empty(): _st=GS.WIN

func _make_expl(ex:float,ey:float) -> ExplosionData:
	var e=ExplosionData.new(); e.init(ex,ey); return e

func _auto_upgrade_collected() -> void:
	# For each card id present in _collected, if the player already owns that id,
	# upgrade the FIRST matching collected card to owned_level+1 (max 3).
	# Further duplicates of the same id stay at level 1.
	var upgraded_ids := {}
	var owned : Array = _player.loop + _player.passives
	for card in _collected:
		var cid = card["id"]
		if cid in upgraded_ids:
			continue  # second instance stays level 1
		var owned_level := 0
		for c in owned:
			if c["id"] == cid:
				owned_level = max(owned_level, c.get("level", 1))
		if owned_level > 0 and owned_level < 3:
			card["level"] = owned_level + 1
			upgraded_ids[cid] = true

func _can_forge() -> bool:
	var loop = _player.loop
	for i in range(loop.size()):
		for j in range(i+1, loop.size()):
			var c1 = loop[i]; var c2 = loop[j]
			if c1["id"] == c2["id"] and max(c1.get("level",1), c2.get("level",1)) < 3:
				return true
	return false

func _make_cdrop(cx:float,cy:float) -> CardDropData:
	var card = _card_drop_queue.pop_front() if not _card_drop_queue.is_empty() else _random_card()
	var cd=CardDropData.new(); cd.init(cx,cy,card); return cd

# ─────────────────────────────────────────────────────────────────────────────
# Drawing
# ─────────────────────────────────────────────────────────────────────────────
var _rng_shake := RandomNumberGenerator.new()

func _draw() -> void:
	# Black starfield background
	draw_rect(Rect2(0, 0, W, H), Color.BLACK)
	var t := Engine.get_process_frames()
	for s in _stars:
		var sy = fmod(s["y"] + t * s["r"] * 0.3, H)
		var twinkle = 0.6 + 0.4 * sin(t * 0.04 + s["x"])
		var b : float = s["b"] * twinkle
		draw_circle(Vector2(s["x"], sy), s["r"], Color(b, b, b))
	# Screen shake offset for game entities
	var sox := 0.0; var soy := 0.0
	if _shake > 0:
		var intensity = (_shake / 20.0) * 6.0
		sox = _rng_shake.randf_range(-intensity, intensity)
		soy = _rng_shake.randf_range(-intensity, intensity)
	_draw_sox = sox; _draw_soy = soy
	draw_set_transform(Vector2(sox, soy))
	_draw_entities()
	draw_set_transform(Vector2.ZERO)
	_draw_hud()
	_draw_overlay()

func _draw_entities() -> void:
	match _st:
		GS.WAVE_INTRO:
			if _player: _draw_player()
		GS.PLAYING, GS.EVO_FLASH:
			if _fleet:  _draw_fleet(_fleet)
			if _player: _draw_player()
			_draw_bullets()
			_draw_expls()
			for cd in _cdrops: _draw_card_drop(cd)
		GS.CARD_SELECT, GS.CARD_FORGE, GS.CARD_ARRANGE:
			pass
		GS.BOSS_INTRO:
			if _player: _draw_player()
		GS.BOSS:
			if _boss and _boss.alive: _draw_boss()
			if _boss_minions:         _draw_fleet(_boss_minions)
			if _player:               _draw_player()
			_draw_bullets()
			_draw_expls()
		GS.BOSS_DEATH:
			if _boss_minions: _draw_fleet(_boss_minions)
			if _player:       _draw_player()
			_draw_bullets()
			_draw_expls()
		GS.PAUSED:
			if _boss and _boss.alive: _draw_boss()
			if _fleet:  _draw_fleet(_fleet)
			if _player: _draw_player()
			_draw_bullets()
			_draw_expls()
			for cd in _cdrops: _draw_card_drop(cd)
		GS.GAME_OVER, GS.WIN:
			if _fleet:  _draw_fleet(_fleet)
			if _player: _draw_player()
			_draw_bullets()
			_draw_expls()
	_draw_muzzle_flashes()
	_draw_float_texts()

func _draw_muzzle_flashes() -> void:
	for mf in _muzzle_flashes:
		var alpha = float(mf["timer"]) / float(mf["total"])
		var col   = Color(mf["color"].r * 1.5, mf["color"].g * 1.5, mf["color"].b * 1.5, alpha)
		_draw_sprite_centered(_spr["expl"], 0, Vector2(mf["x"], mf["y"]), mf["scale"], col)

func _draw_float_texts() -> void:
	for ft in _float_texts:
		var alpha = float(ft["timer"]) / float(ft["total"])
		var col   = Color(ft["color"].r, ft["color"].g, ft["color"].b, alpha)
		var sz    = ft["size"] as int
		draw_string(_font, Vector2(ft["x"] - 60, ft["y"] + sz),
			ft["text"], HORIZONTAL_ALIGNMENT_CENTER, 120, sz, col)

func _draw_sprite_centered(frames:Array, fi:int, pos:Vector2, scale:float=1.0, tint:Color=Color.WHITE) -> void:
	var tex : AtlasTexture = frames[fi % frames.size()]
	var sz  := Vector2(tex.region.size) * scale
	draw_texture_rect(tex, Rect2(pos - sz*0.5, sz), false, tint)

func _draw_player() -> void:
	var p = _player
	if p.hit_expl_timer > 0:
		_draw_sprite_centered(_spr["expl"], p.hit_expl_fi, Vector2(p.hit_expl_x,p.hit_expl_y), 3.0)
		return
	# dash ghost trail
	var trail_key = "ship_left" if p.dash_vx < 0 else "ship_right"
	for ghost in p.dash_trail:
		var alpha = float(ghost["t"]) / 8.0 * 0.55
		_draw_sprite_centered(_spr[trail_key], ghost["fi"], Vector2(ghost["x"], ghost["y"]), 2.2,
			Color(0.4, 0.7, 1.0, alpha))
	if p.invincible > 0 and (p.invincible / 6) % 2 == 0: return
	var key  = "ship_"+p.facing
	var tint = Color.WHITE
	if _ship_flash_timer > 0:
		var t = float(_ship_flash_timer) / 4.0
		tint = Color(1.0 + _ship_flash_col.r * t * 0.6,
					 1.0 + _ship_flash_col.g * t * 0.6,
					 1.0 + _ship_flash_col.b * t * 0.6)
	_draw_sprite_centered(_spr[key], p.fi, Vector2(p.x,p.y), 2.2, tint)

const _ENEMY_NFRAMES := {"e_sml":2, "e_med":4, "e_big":2}
const _ENEMY_SCALE   := {"e_sml":2.0, "e_med":2.0, "e_big":1.0}

func _draw_fleet(fleet: FleetData) -> void:
	for e in fleet.enemies:
		if not e.alive: continue
		if e.y + 16 < 0: continue
		var frames = _spr[e.key]
		var nf     = _ENEMY_NFRAMES[e.key]
		var fi     = fleet.frame_idx % nf
		var scale  = _ENEMY_SCALE[e.key]
		var tint := Color.WHITE
		if e.flash_timer > 0:
			tint = Color(1.627, 0.5, 0.5)
		elif e.charging:
			tint = Color(2.5, 0.3, 0.3)
		elif e.carries_card and (Engine.get_process_frames() / 12) % 2 == 0:
			tint = Color(3.0, 3.0, 3.0)
		_draw_sprite_centered(frames, fi, Vector2(e.x,e.y), scale, tint)

func _draw_boss() -> void:
	var b   = _boss
	var tint = Color.WHITE
	if b.flash_t > 0 and b.flash_t % 4 < 2: tint=Color(2,2,2)
	_draw_sprite_centered(_spr["boss"], b.fi, Vector2(b.x,b.y), 3.0, tint)

func _draw_bullets() -> void:
	for b in _pbullets:
		_draw_sprite_centered(_spr["bolt_player"], b.fi, Vector2(b.x,b.y), b.bscale * 1.35, Color.WHITE)
		_draw_sprite_centered(_spr["bolt_player"], b.fi, Vector2(b.x,b.y), b.bscale, Color(0.9,0.1,0.1))
	for b in _ebullets: _draw_sprite_centered(_spr["bolt_enemy"],  b.fi, Vector2(b.x,b.y))

func _draw_expls() -> void:
	for e in _expls: _draw_sprite_centered(_spr["expl"], e.fi, Vector2(e.x,e.y), 3.0)

func _draw_card_drop(cd: CardDropData) -> void:
	var col = CARD_COLORS[cd.card["category"]]
	var hw  = CardDropData.W_D / 2.0
	var hh  = CardDropData.H_D / 2.0
	draw_set_transform(Vector2(cd.x + _draw_sox, cd.y + _draw_soy), cd.rotation)
	draw_rect(Rect2(-hw, -hh, CardDropData.W_D, CardDropData.H_D), col)
	draw_rect(Rect2(-hw, -hh, CardDropData.W_D, CardDropData.H_D), WHITE, false, 1.0)
	draw_rect(Rect2(-hw + 2.0, -hh + 2.0, 3, 3), WHITE)
	draw_set_transform(Vector2(_draw_sox, _draw_soy))  # restore shake

# ─────────────────────────────────────────────────────────────────────────────
# HUD drawing
# ─────────────────────────────────────────────────────────────────────────────
func _draw_hud() -> void:
	if _st not in [GS.MENU, GS.CARD_SELECT, GS.CARD_FORGE, GS.CARD_ARRANGE, GS.CARD_OP]:
		_draw_evo_bar()
	if _st in [GS.MENU, GS.CARD_SELECT, GS.CARD_FORGE, GS.CARD_ARRANGE, GS.CARD_OP, GS.EVO_FLASH]: return

	if _player:
		# score
		_ds("SCORE  %06d" % _score, Vector2(10, 10+8), WHITE, 8)
		# wave name (not during boss)
		if _st not in [GS.BOSS, GS.BOSS_INTRO, GS.BOSS_DEATH] and _wave < WAVE_NAMES.size():
			_dc(WAVE_NAMES[_wave], 10.0, CYAN, 8)
		# mute
		var ml = "MUTE" if _muted else "M"
		var mc = Color(0.784,0.314,0.314) if _muted else Color(0.314,0.314,0.314)
		_ds(ml, Vector2(10, H-16), mc, 8)
		# HP bar
		_draw_player_bars()
		# card loop indicator
		_draw_card_loop()
		# cards collected
	# boss HP bar (also shown in paused-during-boss)
	if _boss and _st in [GS.BOSS, GS.BOSS_DEATH, GS.PAUSED]:
		_draw_boss_hp()

func _draw_player_bars() -> void:
	var p    = _player
	var bar_w = 80.0; var bar_h = 4.0
	var bx   = p.x - bar_w/2
	var by_hp = p.y + 18.0
	# HP bar
	var hp_fill = int(bar_w * p.lives / float(p.max_lives))
	draw_rect(Rect2(bx, by_hp, bar_w, bar_h), Color(0.039,0.157,0.039))
	draw_rect(Rect2(bx, by_hp, hp_fill, bar_h), Color(0.118,0.863,0.118))
	draw_rect(Rect2(bx, by_hp, bar_w, bar_h), Color(0.314,1.0,0.314), false, 1.0)
	# energy bar
	var by_en = by_hp + bar_h + 3
	var en_fill = int(bar_w * p.energy_pool / float(p.max_energy))
	var starved = p.is_starved()
	var blink_red = starved and (p.loop_timer / 6) % 2 == 0
	var en_bg  = Color(0.235,0.039,0.039) if blink_red else Color(0.157,0.118,0.0)
	var en_fc  = Color(0.863,0.118,0.118) if blink_red else Color(1.0,0.843,0.0)
	var en_brd = Color(1,0.314,0.314)     if blink_red else Color(1.0,0.941,0.314)
	draw_rect(Rect2(bx, by_en, bar_w, bar_h), en_bg)
	draw_rect(Rect2(bx, by_en, en_fill, bar_h), en_fc)
	draw_rect(Rect2(bx, by_en, bar_w, bar_h), en_brd, false, 1.0)
	# salvo charge bar
	if p.salvo_charge >= 6:
		var fill_w = int(44 * min(float(p.salvo_charge-6),54)/54.0)
		var sbx = p.x - 22; var sby = by_en + bar_h + 3
		draw_rect(Rect2(sbx, sby, 44, bar_h), Color(0.235,0.235,0.235))
		draw_rect(Rect2(sbx, sby, fill_w, bar_h), YELLOW)
		draw_rect(Rect2(sbx, sby, 44, bar_h), Color(1,0.941,0.471), false, 1.0)

func _draw_card_loop() -> void:
	var p = _player
	if p.loop.is_empty(): return
	var dot_w := 14.0; var dot_h := 19.0; var gap := 4.0
	var total_w = p.loop.size() * (dot_w+gap) - gap
	var sx = (W - total_w) / 2.0
	var sy = float(H) - dot_h - 6.0
	for i in range(p.loop.size()):
		var card = p.loop[i]
		var cx   = sx + i*(dot_w+gap)
		var col  = CARD_COLORS[card["category"]]
		var dark = col * Color(0.25,0.25,0.25,1)
		var is_active   = (i == p.loop_idx)
		var is_flashing = (i == p.loop_flash_idx and p.loop_flash > 0)
		var r = Rect2(cx, sy, dot_w, dot_h)
		if is_flashing:
			var flash_col = WHITE if (p.loop_flash/3)%2==0 else col
			draw_rect(r, flash_col)
			draw_rect(r, WHITE, false, 2.0)
		elif is_active:
			var progress = float(p.loop_timer) / float(PlayerData.effective_cycle(card))
			var fill_h   = int(dot_h * progress)
			draw_rect(r, dark)
			if fill_h > 0: draw_rect(Rect2(cx, sy+dot_h-fill_h, dot_w, fill_h), col)
			var blink_col = WHITE if (p.loop_timer/8)%2==0 else Color(0.549,0.549,0.549)
			draw_rect(r, blink_col, false, 2.0)
			if p.is_starved() and (p.loop_timer/6)%2==0:
				draw_line(r.position, r.end, RED, 2.0)
				draw_line(Vector2(r.position.x+r.size.x, r.position.y), Vector2(r.position.x, r.position.y+r.size.y), RED, 2.0)
		else:
			draw_rect(r, col)
			draw_rect(r, Color(0.314,0.314,0.314), false, 1.0)
		# Level pip dots (top-left corner): 1-3 gold squares
		var lvl = card.get("level", 1)
		for lv in range(lvl):
			draw_rect(Rect2(cx+1+lv*4, sy+1, 3, 3), Color(1.0, 0.9, 0.2))

func _draw_evo_bar() -> void:
	var SEG     := 5
	var BAR_W   := 8.0
	var SEG_H   := 18.0
	var SEG_GAP := 3.0
	var BY_BOT  := float(H) - 24.0

	# Right bar: kill progress (purple)
	var BX_R := float(W) - BAR_W - 6.0
	var EVO_DARK := Color(0.18, 0.04, 0.28)
	var EVO_LIT  := Color(0.698, 0.275, 1.0)
	var EVO_BRD  := Color(0.82, 0.5, 1.0)
	for i in range(SEG):
		var seg_y = BY_BOT - i * (SEG_H + SEG_GAP)
		var filled = (_evo_kills > i * (_evo_kill_target() / SEG)) or (_evo_ready and (Engine.get_process_frames() / 6) % 2 == 0)
		draw_rect(Rect2(BX_R, seg_y, BAR_W, SEG_H), EVO_DARK)
		if filled:
			draw_rect(Rect2(BX_R, seg_y, BAR_W, SEG_H), EVO_LIT)
		draw_rect(Rect2(BX_R, seg_y, BAR_W, SEG_H), EVO_BRD, false, 1.0)

	# Left bar: card collection progress (yellow) — 2 segments = 2 cards per wave
	var BX_L    := 6.0
	var CD_DARK := Color(0.18, 0.15, 0.02)
	var CD_LIT  := Color(1.0,  0.85, 0.1)
	var CD_BRD  := Color(1.0,  1.0,  0.5)
	for i in range(EVO_CARDS):
		var seg_y = BY_BOT - i * (SEG_H + SEG_GAP)
		var filled = _collected.size() > i
		draw_rect(Rect2(BX_L, seg_y, BAR_W, SEG_H), CD_DARK)
		if filled:
			draw_rect(Rect2(BX_L, seg_y, BAR_W, SEG_H), CD_LIT)
		draw_rect(Rect2(BX_L, seg_y, BAR_W, SEG_H), CD_BRD, false, 1.0)

func _draw_evo_flash() -> void:
	# dim overlay
	draw_rect(Rect2(0, 0, W, H), Color(0, 0, 0, 0.45))
	var blink_on = (_evo_flash_timer / 8) % 2 == 0
	if blink_on:
		var col = Color(0.698, 0.275, 1.0)
		_dc("EVOLUTION", float(H)/2 - 24, col, 20)
		_dc("AVAILABLE", float(H)/2 + 8,  col, 20)

func _draw_boss_hp() -> void:
	var bar_w := 200.0; var bar_h := 10.0
	var bx    = (W-bar_w)/2.0; var by = 36.0
	draw_rect(Rect2(bx,by,bar_w,bar_h), Color(0.235,0.039,0.039))
	var fill = bar_w * max(_boss.hp,0) / float(BossData.MAX_HP)
	draw_rect(Rect2(bx,by,fill,bar_h), Color(0.784,0.118,0.118))
	draw_rect(Rect2(bx,by,bar_w,bar_h), Color(1,0.314,0.314), false, 1.0)
	_dc("THE ARCHITECT", by - 10.0, RED, 8)

# ─────────────────────────────────────────────────────────────────────────────
# Overlay screens (menus, game states)
# ─────────────────────────────────────────────────────────────────────────────
func _draw_overlay() -> void:
	match _st:
		GS.MENU:        _draw_menu()
		GS.WAVE_INTRO:  _draw_wave_intro()
		GS.BOSS_INTRO:  _draw_boss_intro()
		GS.CARD_SELECT:  _draw_card_arrange()  # should not normally be reached
		GS.CARD_FORGE:   _draw_card_forge()
		GS.CARD_ARRANGE: _draw_card_arrange()
		GS.CARD_OP:      _draw_card_op()
		GS.CARD_REPLACE: _draw_card_replace()
		GS.EVO_FLASH:    _draw_evo_flash()
		GS.PAUSED:      _draw_paused()
		GS.GAME_OVER:   _draw_game_over()
		GS.WIN:         _draw_win()

func _draw_menu() -> void:
	_dc("AUTO",   float(H)/2-160, CYAN,  24)
	_dc("SHMUP",  float(H)/2-100, WHITE, 24)
	draw_line(Vector2(60,float(H)/2-52), Vector2(W-60,float(H)/2-52), CYAN, 1.0)
	var MENU_ITEMS = ["START GAME","EXIT GAME"]
	for i in range(2):
		var col    = CYAN  if i==_menu_sel else WHITE
		var prefix = ">  " if i==_menu_sel else "   "
		_dc(prefix+MENU_ITEMS[i], float(H)/2-20+i*52, col, 16)
	_dc("UP / DOWN    navigate", float(H)-70, Color(0.392,0.392,0.392), 8)
	_dc("ENTER / SPACE  select", float(H)-48, Color(0.392,0.392,0.392), 8)

func _draw_wave_intro() -> void:
	if _wave < WAVE_NAMES.size() and (_wave_timer/15)%2==0:
		_dc(WAVE_NAMES[_wave], float(H)/2-16, CYAN, 16)

func _draw_boss_intro() -> void:
	if (_boss_timer/15)%2==0:
		_dc("THE ARCHITECT", float(H)/2-16, RED, 16)

func _draw_paused() -> void:
	draw_rect(Rect2(0,0,W,H), Color(0,0,0,0.549))
	_dc("PAUSED", float(H)/2-60, CYAN, 16)
	var PAUSE_ITEMS = ["RESUME","QUIT"]
	for i in range(2):
		var col    = CYAN  if i==_pause_sel else WHITE
		var prefix = ">  " if i==_pause_sel else "   "
		_dc(prefix+PAUSE_ITEMS[i], float(H)/2+i*48, col, 16)

func _draw_card_select() -> void:
	draw_rect(Rect2(0,0,W,H), DARK_BG)
	_dc("CHOOSE CARD", 20.0, CYAN, 16)
	_dc("add to your loop", 46.0, WHITE, 8)
	draw_line(Vector2(20,60), Vector2(W-20,60), Color(0.314,0.314,0.314), 1.0)
	for i in range(_collected.size()):
		var card = _collected[i]
		var y    = 70.0 + i*34.0
		var col  = CARD_COLORS[card["category"]]
		var sel  = i in _csel_chosen
		var cur  = i == _csel_cursor
		var is_manip = card.get("effect","") in ["deck_remove","deck_fuse","deck_upgrade"]
		draw_rect(Rect2(20, y+2, 12, 16), col)
		draw_rect(Rect2(20, y+2, 12, 16), WHITE, false, 1.0)
		var prefix = "> " if cur  else "  "
		var check  = "[x] " if sel else "[ ] "
		var tc     = YELLOW if (is_manip and cur) else (WHITE if sel else Color(0.627,0.627,0.627))
		var display_name = card["name"] if is_manip else (card["name"]+" "+_lvl_str(card))
		_ds(prefix+check+display_name, Vector2(38, y+12), tc, 8)
		var ce = _card_energy(card)
		if ce != 0:
			var esign = "+%d"%ce if ce>0 else str(ce)
			var ec    = YELLOW if ce>0 else RED
			_ds(esign, Vector2(W-30, y+12), ec, 8)
	var sep_y = 70.0 + CARDS_TO_END*34.0 + 4
	draw_line(Vector2(20,sep_y), Vector2(W-20,sep_y), Color(0.314,0.314,0.314), 1.0)
	_dc("ADDING %d / 1 CARD" % _csel_chosen.size(), sep_y+10, CYAN, 8)
	if _card_op_msg != "":
		_dc(_card_op_msg, sep_y+24, RED, 8)
	else:
		_dc("SPC:choose", sep_y+24, Color(0.471,0.471,0.471), 8)

func _draw_card_forge() -> void:
	draw_rect(Rect2(0,0,W,H), DARK_BG)
	_dc("FORGE", 20.0, YELLOW, 16)
	var subtitle := "SELECT FIRST CARD" if _cforge_sel1 == -1 else "SELECT CARD TO MERGE WITH"
	_dc(subtitle, 46.0, WHITE, 8)
	draw_line(Vector2(20,60), Vector2(W-20,60), Color(0.314,0.314,0.314), 1.0)
	var n  = _player.loop.size()
	if n > 0:
		var cw  = int(clamp((W-24.0)/n-4, 28, 44))
		var ch  = 56.0; var gap = 4.0
		var tw  = n*(cw+gap)-gap
		var ox  = (W-tw)/2.0; var oy = H/2.0 - ch/2.0
		for i in range(n):
			var card      = _player.loop[i]
			var cx        = ox + i*(cw+gap)
			var col       = CARD_COLORS[card["category"]]
			var dark      = col * Color(0.25,0.25,0.25,1)
			var is_cursor = (i == _cforge_cursor)
			var is_sel1   = (i == _cforge_sel1)
			var flashing  = is_sel1 and _cforge_flash_timer == 0
			var cy        = oy - 8.0 if is_cursor else oy
			if is_sel1: draw_rect(Rect2(cx-2,cy-2,cw+4,ch+4), YELLOW)
			draw_rect(Rect2(cx,cy,cw,ch), col if flashing else dark)
			draw_rect(Rect2(cx,cy,cw,6), col)
			var border = YELLOW if is_sel1 else (CYAN if is_cursor else Color(0.314,0.314,0.314))
			draw_rect(Rect2(cx,cy,cw,ch), border, false, 2.0)
			# blink result card
			if _cforge_flash_timer > 0 and i == _cforge_result_idx:
				var blink = (_cforge_flash_timer / 6) % 2 == 0
				if blink:
					draw_rect(Rect2(cx-4,cy-4,cw+8,ch+8), Color(1,0.9,0.2,0.8))
			var words = card["name"].split(" ")
			var line_y = cy + 10.0
			for word in words:
				_ds_centered(word, cx, cw, line_y, WHITE, 8); line_y+=9
			_ds_centered(_lvl_str(card), cx, cw, cy+ch-10, YELLOW, 8)
			if is_cursor and _cforge_flash_timer == 0:
				_ds_centered("^", cx, cw, oy+ch+6, CYAN, 8)
	if _cforge_msg != "":
		_dc(_cforge_msg, float(H)*0.72, RED, 8)
	draw_line(Vector2(20,H-36), Vector2(W-20,H-36), Color(0.314,0.314,0.314), 1.0)
	_dc("L/R:move  SPC:select  ESC:skip", float(H)-26, Color(0.471,0.471,0.471), 8)

func _draw_card_arrange() -> void:
	draw_rect(Rect2(0,0,W,H), DARK_BG)
	_dc("SHIP SYSTEMS", 20.0, CYAN, 16)
	draw_line(Vector2(20,36), Vector2(W-20,36), Color(0.314,0.314,0.314), 1.0)

	var has_cards  = _collected.size() > 0
	var loop_top   : float

	# ── Card pick section (shown when cards are available) ──────────────────
	if has_cards:
		var pick_col = CYAN if _arr_focus == 0 else Color(0.4,0.4,0.4)
		_dc("PICK A CARD", 46.0, pick_col, 8)
		var card_row_h := 26.0
		for i in range(_collected.size()):
			var card = _collected[i]
			var ry   = 57.0 + i * card_row_h
			var col  = CARD_COLORS[card["category"]]
			var cur  = (i == _csel_cursor and _arr_focus == 0)
			draw_rect(Rect2(20, ry+2, 10, 14), col)
			var prefix = "> " if cur else "  "
			var tc     = WHITE if cur else Color(0.55,0.55,0.55)
			_ds(prefix + card["name"] + " " + _lvl_str(card), Vector2(36, ry+12), tc, 8)
			var ce = _card_energy(card)
			if ce != 0:
				var esign = "+%d"%ce if ce>0 else str(ce)
				_ds(esign, Vector2(W-30, ry+12), YELLOW if ce>0 else RED, 8)
		var sep_y = 57.0 + _collected.size() * card_row_h + 4.0
		draw_line(Vector2(20, sep_y), Vector2(W-20, sep_y), Color(0.314,0.314,0.314), 1.0)
		loop_top = sep_y + 10.0
	else:
		loop_top = 46.0

	# ── Loop arrange section ────────────────────────────────────────────────
	var loop_col  = CYAN if (_arr_focus == 1 or not has_cards) else Color(0.4,0.4,0.4)
	_dc("WEAPONS", loop_top + 2.0, loop_col, 7)
	var n    = _player.loop.size()
	var NW_W = 44.0
	var ch   = 52.0; var gap = 4.0
	var cw   = int(clamp((W - 24.0 - NW_W - 6.0) / max(n,1) - 4, 26, 42))
	var tw   = n*(cw+gap) + NW_W + gap
	var ox   = (W-tw)/2.0
	var oy_base = loop_top + 14.0

	for i in range(n):
		var card      = _player.loop[i]
		var cx        = ox + i*(cw+gap)
		var col       = CARD_COLORS[card["category"]]
		var is_cursor = (i == _arr_cursor and (_arr_focus == 1 or not has_cards))
		var is_held   = (_arr_held != null and i == _arr_held)
		var cy        = oy_base - 8 if is_held else oy_base
		var dark      = col * Color(0.25,0.25,0.25,1)
		if is_held: draw_rect(Rect2(cx-1,cy-1,cw+2,ch+2), WHITE)
		draw_rect(Rect2(cx,cy,cw,ch), dark if not is_held else col)
		draw_rect(Rect2(cx,cy,cw,6), col)
		var border = WHITE if is_held else (CYAN if is_cursor else Color(0.25,0.25,0.25))
		draw_rect(Rect2(cx,cy,cw,ch), border, false, 2.0)
		var words = card["name"].split(" ")
		var line_y = cy + 10.0
		for word in words:
			_ds_centered(word, cx, cw, line_y, WHITE, 7); line_y+=8
		_ds_centered(_lvl_str(card), cx, cw, cy+ch-10, YELLOW, 7)
		var ce = _card_energy(card)
		if ce != 0:
			var esign = "+%d"%ce if ce>0 else str(ce)
			_ds_centered(esign, cx, cw, cy+ch-2, YELLOW if ce>0 else RED, 7)
		if is_cursor and _arr_held==null:
			_ds_centered("^", cx, cw, oy_base+ch+5, CYAN, 7)
	# NEXT WAVE / CLOSE card
	var nw_cx  = ox + n*(cw+gap)
	var nw_cur = (_arr_cursor == n and (_arr_focus == 1 or not has_cards))
	var nw_col = Color(0.1, 0.6, 0.2)
	draw_rect(Rect2(nw_cx, oy_base, NW_W, ch), Color(0.04,0.15,0.06))
	draw_rect(Rect2(nw_cx, oy_base, NW_W, 6), nw_col)
	draw_rect(Rect2(nw_cx, oy_base, NW_W, ch), CYAN if nw_cur else Color(0.25,0.25,0.25), false, 2.0)
	var nw_label = ["CLOSE",""] if _arr_from_playing else ["NEXT","WAVE"]
	_ds_centered(nw_label[0], nw_cx, NW_W, oy_base+13, nw_col, 7)
	if nw_label[1] != "": _ds_centered(nw_label[1], nw_cx, NW_W, oy_base+24, nw_col, 7)
	if nw_cur and _arr_held == null:
		_ds_centered("^", nw_cx, NW_W, oy_base+ch+5, CYAN, 7)

	# Energy summary + passives
	var below = oy_base + ch + 8.0
	var gen = 0; var cost = 0
	for c in _player.loop + _player.passives:
		var ce = _card_energy(c)
		if ce>0: gen += ce
		else: cost += ce
	var net_col = Color(0.235,0.863,0.392) if gen+cost>=0 else RED
	_dc("+%d gen  %d cost  net %+d/cycle"%[gen,cost,gen+cost], below + 12.0, net_col, 7)

	var ps_y  = below + 28.0
	_dc("PASSIVES  %d / 2" % _player.passives.size(), ps_y - 2.0, Color(0.6,0.6,0.6), 7)
	var ps_cw = 44.0; var ps_ch = 48.0; var ps_gap = 8.0
	var ps_ox = (W - 2*(ps_cw+ps_gap)) / 2.0
	ps_y += 10.0
	for i in range(2):
		var px = ps_ox + i*(ps_cw+ps_gap); var py = ps_y
		if i < _player.passives.size():
			var pc  = _player.passives[i]
			var col = CARD_COLORS.get(pc["category"], WHITE)
			draw_rect(Rect2(px,py,ps_cw,ps_ch), col * 0.2)
			draw_rect(Rect2(px,py,ps_cw,6), col)
			draw_rect(Rect2(px,py,ps_cw,ps_ch), col, false, 1.5)
			var words = pc["name"].split(" ")
			var ly = py + 10.0
			for word in words: _ds_centered(word, px, ps_cw, ly, WHITE, 7); ly+=8
			_ds_centered(_lvl_str(pc), px, ps_cw, py+ps_ch-10, YELLOW, 7)
			var ce = _card_energy(pc)
			if ce != 0:
				var esign = "+%d"%ce if ce>0 else str(ce)
				_ds_centered(esign, px, ps_cw, py+ps_ch-2, YELLOW if ce>0 else RED, 7)
		else:
			draw_rect(Rect2(px,py,ps_cw,ps_ch), Color(0.08,0.08,0.08))
			draw_rect(Rect2(px,py,ps_cw,ps_ch), Color(0.25,0.25,0.25), false, 1.0)
			_ds_centered("EMPTY", px, ps_cw, py+ps_ch/2-4, Color(0.4,0.4,0.4), 7)

	draw_line(Vector2(20,H-36), Vector2(W-20,H-36), Color(0.314,0.314,0.314), 1.0)
	var hint2 = "TAB:switch section  " if has_cards else ""
	var close_hint = "I/ESC:close" if _arr_from_playing else "SPC:next wave"
	_dc("%sSPC:pick/drop  L/R:move  Z:del  %s" % [hint2, close_hint], float(H)-26, Color(0.471,0.471,0.471), 7)

func _draw_card_replace() -> void:
	draw_rect(Rect2(0,0,W,H), DARK_BG)
	_dc("DECK FULL", 20.0, RED, 16)
	_dc("select card to replace", 46.0, WHITE, 8)
	draw_line(Vector2(20,60), Vector2(W-20,60), Color(0.314,0.314,0.314), 1.0)
	# New card preview
	var ncy = 80.0; var ncw = 44.0; var nch = 56.0
	var nc = _replace_card
	var ncol = CARD_COLORS.get(nc.get("category",""), WHITE)
	draw_rect(Rect2(W/2-ncw/2, ncy, ncw, nch), ncol*0.2)
	draw_rect(Rect2(W/2-ncw/2, ncy, ncw, 6), ncol)
	draw_rect(Rect2(W/2-ncw/2, ncy, ncw, nch), ncol, false, 2.0)
	_dc("NEW", ncy+10, WHITE, 7)
	_dc(nc.get("name","?"), ncy+22, WHITE, 7)
	_ds_centered(_lvl_str(nc), W/2-ncw/2, ncw, ncy+nch-10, YELLOW, 7)
	_dc("replace which?", ncy+nch+14, CYAN, 8)
	# Existing loop cards
	var n = _player.loop.size()
	var cw = int(clamp((W-24.0)/max(n,1)-4, 28, 44))
	var ch = 56.0; var gap = 4.0
	var tw = n*(cw+gap); var ox = (W-tw)/2.0; var oy = ncy+nch+32.0
	for i in range(n):
		var card = _player.loop[i]
		var cx = ox + i*(cw+gap); var cy = oy
		var is_cur = (i == _replace_cursor)
		var col2 = CARD_COLORS.get(card["category"], WHITE)
		draw_rect(Rect2(cx,cy,cw,ch), col2*0.15)
		draw_rect(Rect2(cx,cy,cw,6), col2)
		var border = CYAN if is_cur else Color(0.314,0.314,0.314)
		draw_rect(Rect2(cx,cy,cw,ch), border, false, 2.0)
		var words = card["name"].split(" "); var ly = cy+10.0
		for word in words: _ds_centered(word, cx, cw, ly, WHITE, 7); ly+=8
		_ds_centered(_lvl_str(card), cx, cw, cy+ch-10, YELLOW, 7)
		if is_cur: _ds_centered("^", cx, cw, oy+ch+6, CYAN, 8)
	draw_line(Vector2(20,H-36), Vector2(W-20,H-36), Color(0.314,0.314,0.314), 1.0)
	_dc("SPC:replace  L/R:move", float(H)-26, Color(0.471,0.471,0.471), 8)

func _draw_game_over() -> void:
	_dc("GAME OVER",  float(H)/2-30, RED,   16)
	_dc("SCORE  %06d"%_score, float(H)/2+10, WHITE, 8)
	_dc("press R for menu",   float(H)/2+40, CYAN,  8)

func _draw_win() -> void:
	_dc("YOU WIN!",   float(H)/2-30, YELLOW, 16)
	_dc("SCORE  %06d"%_score, float(H)/2+10, WHITE,  8)
	_dc("press R for menu",   float(H)/2+40, CYAN,   8)

# ─────────────────────────────────────────────────────────────────────────────
# Drawing helpers
# ─────────────────────────────────────────────────────────────────────────────
func _ds(text:String, pos:Vector2, color:Color, size:int) -> void:
	draw_string(_font, pos + Vector2(0, size), text,
		HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func _dc(text:String, y:float, color:Color, size:int) -> void:
	draw_string(_font, Vector2(0, y+size), text,
		HORIZONTAL_ALIGNMENT_CENTER, W, size, color)

func _ds_centered(text:String, cx:float, w:float, y:float, color:Color, size:int) -> void:
	draw_string(_font, Vector2(cx, y+size), text,
		HORIZONTAL_ALIGNMENT_CENTER, w, size, color)

func _lvl_str(card: Dictionary) -> String:
	match card.get("level", 1):
		2: return "II"
		3: return "III"
	return "I"

func _card_energy(card: Dictionary) -> int:
	if card.get("effect", "") == "passive":
		return card.get("level", 1) + 1
	if card.get("effect", "") == "main_shot":
		return -(card.get("level", 1) - 1)  # I=0  II=-1  III=-2
	return card["energy"] as int

# ─────────────────────────────────────────────────────────────────────────────
# Card operation screen
# ─────────────────────────────────────────────────────────────────────────────
func _draw_card_op() -> void:
	draw_rect(Rect2(0,0,W,H), DARK_BG)
	var subtitle := "SELECT FIRST CARD" if _card_op_sel1 == -1 else "SELECT MATCHING CARD"
	_dc("FORGE", 16.0, YELLOW, 16)
	_dc(subtitle, 44.0, WHITE, 8)
	draw_line(Vector2(20,60), Vector2(W-20,60), Color(0.314,0.314,0.314), 1.0)

	if not _player or _player.loop.is_empty():
		_dc("LOOP IS EMPTY", H/2.0-8, Color(0.627,0.627,0.627), 8)
	else:
		var n   = _player.loop.size()
		var cw  = int(clamp((W-24.0)/n-4, 28, 44))
		var ch  = 60.0; var gap = 4.0
		var tw  = n*(cw+gap)-gap
		var ox  = (W-tw)/2.0; var oy = H/2.0 - ch/2.0
		for i in range(n):
			var card      = _player.loop[i]
			var cx        = ox + i*(cw+gap)
			var col       = CARD_COLORS[card["category"]]
			var dark      = col * Color(0.25,0.25,0.25,1)
			var is_cursor = (i == _card_op_cursor)
			var is_sel1   = (i == _card_op_sel1)
			var cy        = oy - 8.0 if is_cursor else oy
			if is_sel1:
				draw_rect(Rect2(cx-2,cy-2,cw+4,ch+4), YELLOW)
			draw_rect(Rect2(cx,cy,cw,ch), col if is_cursor else dark)
			draw_rect(Rect2(cx,cy,cw,6), col)
			var border_col: Color
			if is_sel1:    border_col = YELLOW
			elif is_cursor: border_col = WHITE
			else:           border_col = Color(0.314,0.314,0.314)
			draw_rect(Rect2(cx,cy,cw,ch), border_col, false, 2.0)
			var words = card["name"].split(" ")
			var line_y = cy + 10.0
			for word in words:
				_ds_centered(word, cx, cw, line_y, WHITE, 8); line_y+=9
			_ds_centered(_lvl_str(card), cx, cw, cy+ch-10, YELLOW, 8)
			if is_cursor:
				_ds_centered("^", cx, cw, oy+ch+6, CYAN, 8)

	if _card_op_msg != "":
		_dc(_card_op_msg, H*0.72, RED, 8)

	draw_line(Vector2(20,H-36), Vector2(W-20,H-36), Color(0.314,0.314,0.314), 1.0)
	_dc("L/R:move  X:select  ESC:cancel", float(H)-26, Color(0.471,0.471,0.471), 8)

func _execute_card_op() -> void:
	var loop = _player.loop
	if loop.is_empty(): _arr_focus=0; _st=GS.CARD_ARRANGE; return
	# only deck_fuse remains
	if _card_op_sel1 == -1:
		_card_op_sel1 = _card_op_cursor
		_card_op_msg  = "NOW SELECT MATCHING CARD"
	else:
		if _card_op_cursor == _card_op_sel1:
			_card_op_msg = "PICK A DIFFERENT CARD"
			return
		var i1    = _card_op_sel1
		var i2    = _card_op_cursor
		var card1 = loop[i1]
		var card2 = loop[i2]
		if card1["id"] != card2["id"]:
			_card_op_msg = "CARDS MUST BE IDENTICAL"
			return
		if card1.get("level", 1) != card2.get("level", 1):
			_card_op_msg = "CARDS MUST BE SAME LEVEL"
			return
		var new_lvl = min(max(card1.get("level",1), card2.get("level",1)) + 1, 3)
		var fused = card1.duplicate()
		fused["level"] = new_lvl
		if i1 < i2:
			loop.remove_at(i2); loop.remove_at(i1)
		else:
			loop.remove_at(i1); loop.remove_at(i2)
		var insert_at = min(i1, i2)
		loop.insert(insert_at, fused)
		_card_op_cursor = clamp(insert_at, 0, max(loop.size()-1, 0))
		if _player.loop_idx >= loop.size():
			_player.loop_idx = max(loop.size()-1, 0)
			_player.loop_timer = 0
		_evo_ready = false
		_st = GS.CARD_ARRANGE
