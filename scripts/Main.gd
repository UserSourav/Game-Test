extends Node2D

@export var base_speed := 360.0
@export var speed_increase := 4.0
@export var lane_positions := [380.0, 640.0, 900.0]

@onready var player: Area2D = $Player
@onready var obstacle_timer: Timer = $ObstacleTimer
@onready var coin_timer: Timer = $CoinTimer
@onready var obstacles: Node2D = $Obstacles
@onready var coins: Node2D = $Coins
@onready var score_label: Label = $HUD/ScoreLabel
@onready var game_over_label: Label = $HUD/GameOverLabel
@onready var background_a: ColorRect = $BackgroundA
@onready var background_b: ColorRect = $BackgroundB
@onready var ground_a: ColorRect = $GroundA
@onready var ground_b: ColorRect = $GroundB
@onready var music: AudioStreamPlayer = $Music

var obstacle_scene := preload("res://scenes/Obstacle.tscn")
var coin_scene := preload("res://scenes/Coin.tscn")

var speed := 0.0
var score := 0
var is_game_over := false

var playback: AudioStreamGeneratorPlayback
var synth_phase := 0.0
var note_time := 0.0
var melody := [220.0, 277.0, 330.0, 392.0, 440.0, 392.0, 330.0, 277.0]

func _ready() -> void:
	speed = base_speed
	player.set_lanes(lane_positions)
	player.area_entered.connect(_on_player_area_entered)
	obstacle_timer.timeout.connect(_on_obstacle_timer_timeout)
	coin_timer.timeout.connect(_on_coin_timer_timeout)
	_setup_music()
	_update_score()

func _process(delta: float) -> void:
	if is_game_over:
		if Input.is_action_just_pressed("restart"):
			get_tree().reload_current_scene()
		return

	speed += speed_increase * delta
	_scroll_background(delta)
	_move_spawned(delta)
	_fill_music_buffer(delta)

func _scroll_background(delta: float) -> void:
	var bg_speed = speed * 0.25
	background_a.position.y += bg_speed * delta
	background_b.position.y += bg_speed * delta
	var bg_height = background_a.size.y
	if background_a.position.y >= 720:
		background_a.position.y = background_b.position.y - bg_height
	if background_b.position.y >= 720:
		background_b.position.y = background_a.position.y - bg_height

	ground_a.position.y += speed * delta
	ground_b.position.y += speed * delta
	var ground_height = ground_a.size.y
	if ground_a.position.y >= 720:
		ground_a.position.y = ground_b.position.y - ground_height
	if ground_b.position.y >= 720:
		ground_b.position.y = ground_a.position.y - ground_height

func _move_spawned(delta: float) -> void:
	for obstacle in obstacles.get_children():
		obstacle.position.y += speed * delta
		if obstacle.position.y > 820:
			obstacle.queue_free()
	for coin in coins.get_children():
		coin.position.y += speed * delta
		if coin.position.y > 820:
			coin.queue_free()

func _on_obstacle_timer_timeout() -> void:
	if is_game_over:
		return
	var obstacle = obstacle_scene.instantiate()
	obstacle.position = Vector2(lane_positions.pick_random(), -80)
	obstacles.add_child(obstacle)

func _on_coin_timer_timeout() -> void:
	if is_game_over:
		return
	var coin = coin_scene.instantiate()
	coin.position = Vector2(lane_positions.pick_random(), -60)
	coins.add_child(coin)

func _on_player_area_entered(area: Area2D) -> void:
	if area.is_in_group("coins"):
		area.queue_free()
		score += 5
		_update_score()
		return
	if area.is_in_group("obstacles"):
		_game_over()

func _game_over() -> void:
	if is_game_over:
		return
	is_game_over = true
	game_over_label.visible = true
	obstacle_timer.stop()
	coin_timer.stop()

func _update_score() -> void:
	score_label.text = "Score: %s" % score

func _setup_music() -> void:
	var generator := AudioStreamGenerator.new()
	generator.mix_rate = 44100
	generator.buffer_length = 0.5
	music.stream = generator
	music.play()
	playback = music.get_stream_playback()

func _fill_music_buffer(delta: float) -> void:
	if playback == null:
		return
	var sample_rate = 44100.0
	var needed = playback.get_frames_available()
	if needed <= 0:
		return

	for i in needed:
		var note_index = int(note_time * 2.0) % melody.size()
		var freq = melody[note_index]
		var sample = 0.2 * sin(synth_phase * TAU) + 0.1 * sin(synth_phase * TAU * 2.0)
		playback.push_frame(Vector2(sample, sample))
		synth_phase += freq / sample_rate
		if synth_phase >= 1.0:
			synth_phase -= 1.0
		note_time += 1.0 / sample_rate
