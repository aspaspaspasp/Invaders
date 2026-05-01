class_name CombatSystem
extends Node

const EnemyScript  = preload("res://combat/Enemy.gd")
const BulletScript = preload("res://combat/Bullet.gd")

var train:   Train
var enemies: Node
var bullets: Node

var wave:              int   = 0
var wave_timer:        float = 5.0
var between_waves:     bool  = true
var damage_this_frame: int   = 0
var kill_rewards:      int   = 0
var kill_events:       Array = []
var level_complete:    bool  = false

var _wave_table:         Array = []
var _between_wave_delay: float = 5.0
var _fire_timer:         float = 0.0

const FIRE_INTERVAL := 0.6

func init_from_level(level: LevelData) -> void:
	_wave_table         = level.waves.duplicate()
	_between_wave_delay = level.between_wave_delay
	wave          = 0
	wave_timer    = _between_wave_delay
	between_waves = true
	level_complete = false

func update(delta: float) -> void:
	damage_this_frame = 0
	kill_rewards      = 0
	kill_events.clear()
	if level_complete: return

	if between_waves:
		wave_timer -= delta
		if wave_timer <= 0.0:
			between_waves = false
			_spawn_wave()
	elif enemies.get_child_count() == 0:
		wave += 1
		if wave >= _wave_table.size():
			level_complete = true
			return
		between_waves = true
		wave_timer    = _between_wave_delay

	_check_collisions()

	_fire_timer -= delta
	if _fire_timer <= 0.0:
		_fire_timer = FIRE_INTERVAL
		_fire()

func _fire() -> void:
	train._recalc_trajectory()
	if train.trajectory.size() < 2: return
	var bullet := BulletScript.new() as Bullet
	bullet.setup(train.trajectory.duplicate())
	bullets.add_child(bullet)

func _spawn_wave() -> void:
	var desc: Array = _wave_table[wave]
	var counts := [
		desc[0] if desc.size() > 0 else 0,
		desc[1] if desc.size() > 1 else 0,
		desc[2] if desc.size() > 2 else 0,
		desc[3] if desc.size() > 3 else 0,
		desc[4] if desc.size() > 4 else 0,
	]
	for _i: int in counts[0]: _spawn_enemy(Enemy.Type.GRUNT)
	for _i: int in counts[1]: _spawn_enemy(Enemy.Type.SPEEDER)
	for _i: int in counts[2]: _spawn_enemy(Enemy.Type.TANK)
	for _i: int in counts[3]: _spawn_enemy(Enemy.Type.BOMBER)
	for _i: int in counts[4]: _spawn_enemy(Enemy.Type.BRUTE)

func _spawn_enemy(type: int) -> void:
	var angle := randf() * TAU
	var dist  := 520.0 + randf() * 100.0
	var enemy := EnemyScript.new() as Enemy
	enemy.position = train.position + Vector2(cos(angle), sin(angle)) * dist
	enemies.add_child(enemy)
	enemy.setup(type, train)

func _check_collisions() -> void:
	for b in bullets.get_children():
		var bullet := b as Bullet
		if bullet == null or not bullet.alive: continue
		for e in enemies.get_children():
			var enemy := e as Enemy
			if enemy == null or not enemy.alive: continue
			if bullet.position.distance_to(enemy.position) < Bullet.RADIUS + enemy.radius:
				bullet_hits_enemy(bullet, enemy)
				break

	_check_train_collisions()

func bullet_hits_enemy(bullet, enemy) -> void:
	if enemy.take_hit(Bullet.DAMAGE):
		var reward: int = 2 if enemy.type == Enemy.Type.TANK \
				or enemy.type == Enemy.Type.BRUTE else 1
		kill_rewards += reward
		kill_events.append({"pos": enemy.position, "amount": reward})
		enemy.queue_free()
	bullet.queue_free()

func _check_train_collisions() -> void:
	if train.dead: return
	for e in enemies.get_children():
		var enemy := e as Enemy
		if enemy == null or not enemy.alive: continue
		if enemy.position.distance_to(train.position) < enemy.radius + 20.0:
			enemy.alive = false
			enemy.queue_free()
			damage_this_frame += enemy.damage
