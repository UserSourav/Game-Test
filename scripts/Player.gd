extends Area2D

@export var lane_change_speed := 900.0
@export var y_position := 520.0

var lanes: Array[float] = []
var lane_index := 1
var target_x := 0.0

func _ready() -> void:
	position.y = y_position

func set_lanes(lane_positions: Array[float]) -> void:
	lanes = lane_positions
	lane_index = clamp(lane_index, 0, lanes.size() - 1)
	target_x = lanes[lane_index]
	position.x = target_x

func _physics_process(delta: float) -> void:
	if lanes.is_empty():
		return

	if Input.is_action_just_pressed("move_left"):
		lane_index = max(0, lane_index - 1)
		target_x = lanes[lane_index]
	if Input.is_action_just_pressed("move_right"):
		lane_index = min(lanes.size() - 1, lane_index + 1)
		target_x = lanes[lane_index]

	position.x = move_toward(position.x, target_x, lane_change_speed * delta)
