extends CharacterBody2D

@onready var anchor: Node2D = $Anchor
@onready var animation_player_lower: AnimationPlayer = $AnimationPlayerLower
@onready var animation_player_upper: AnimationPlayer = $AnimationPlayerUpper
@onready var camera: Camera2D = $Camera2D

@export var velocity_camera: float = 600.0
@export var limit_left: float = -400.0
@export var limit_right: float = 400.0

@export var max_speed: = 200.0
@export var acceleration: = 1000.0
@export var friction: = 1000.0
@export var air_friction: = 2000.0
@export var air_acceleration: = 500.0
@export var up_gravity: = 980.0
@export var down_gravity: = 600.0
@export var jump_amount: = 400.0

var fall_start_position: float = 0.0
var was_on_floor: bool = true

func _ready() -> void:
	animation_player_lower.current_animation_changed.connect(func(animation_name: String):
		if animation_player_upper.current_animation == "attack": return
		animation_player_upper.play(animation_name)
	)
	animation_player_upper.animation_finished.connect(func(animation_name: String):
		if animation_name != "attack": return
		animation_player_upper.play(animation_player_lower.current_animation)
		animation_player_upper.seek(animation_player_lower.current_animation_position)
	)

func _physics_process(delta: float) -> void:
	var x_input = Input.get_axis("move_left", "move_right")
	
	# DETECTA INÍCIO DA QUEDA
	if was_on_floor and not is_on_floor():
		fall_start_position = global_position.y
	
	apply_gravity(delta)
	
	if not was_on_floor and is_on_floor():
		var fall_height = global_position.y - fall_start_position
		check_fall_damage(fall_height)
	
	was_on_floor = is_on_floor()
	
	if Input.is_action_just_pressed("attack"):
		animation_player_upper.play("attack")
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_amount
	
	if(x_input == 0):
		apply_friction(delta)
		animation_player_lower.play("idle")
	else:
		accelerate_horizontally(x_input, delta)
		anchor.scale.x = sign(x_input)
		animation_player_lower.play("run")
	
	if not is_on_floor(): # block jump in air
		animation_player_lower.play("jump")
	
	move_and_slide()

func accelerate_horizontally(horizontal_direction: float, delta: float) -> void:
	var acceleration_amount = acceleration
	if not is_on_floor(): acceleration_amount = air_acceleration
	velocity.x = move_toward(velocity.x, max_speed * horizontal_direction, acceleration_amount * delta * abs(horizontal_direction))
	pass

func apply_friction(delta) -> void:
	var friction_amount: = friction
	if not is_on_floor(): friction_amount = air_friction
	velocity.x = move_toward(velocity.x, 0.0, friction_amount * delta)
	pass

func apply_gravity(delta) -> void:
	if not is_on_floor(): 
		if velocity.y <= 0.0:
			velocity.y += up_gravity * delta
		else:
			velocity.y += down_gravity * delta

func check_fall_damage(fall_height: float) -> void:
	if fall_height >= 100.0:
		print(fall_height, " pixels")
		apply_fall_vibration(fall_height)
	elif fall_height >= 6.0:
		print(fall_height, " pixels")
		apply_landing_vibration()
	else: 
		print(fall_height)

func apply_fall_vibration(fall_height: float) -> void:
	if Input.get_connected_joypads().size() > 0:
		var intensity = clamp((fall_height - 100.0) / 300.0, 0.5, 1.0)  # 0.5 a 1.0
		var duration = clamp(fall_height / 500.0, 0.5, 0.8)  # 0.5 a 0.8 segundos
		
		Input.start_joy_vibration(0, intensity, intensity, duration)

func apply_landing_vibration() -> void:
	if Input.get_connected_joypads().size() > 0:
		var intensity = 0.3
		var duration = 0.1
		
		Input.start_joy_vibration(0, intensity, intensity, duration)
		#Input.start_joy_vibration(0, 0.3, 0.3, 0.1)aa

func _process(delta: float) -> void:
	if Input.get_connected_joypads().size() > 0:
		var camera_input_x = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
		var camera_input_y = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
		
		if velocity.x == 0:
			if abs(camera_input_x) > 0.2 or abs(camera_input_y) > 0.2:
				var target_offset_x = camera_input_x * 100.0 # limit distance
				var target_offset_y = camera_input_y * 60.0
				camera.offset.x = lerp(camera.offset.x, target_offset_x, 5 * delta)
				camera.offset.y = lerp(camera.offset.y, target_offset_y, 5 * delta)
			else:  # reset camera 
				camera.offset.x = lerp(camera.offset.x, 0.0, 3.0 * delta)
				camera.offset.y = lerp(camera.offset.y, 0.0, 3.0 * delta)
