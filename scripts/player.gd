extends CharacterBody2D

@onready var anchor: Node2D = $Anchor

@onready var animation_player_lower: AnimationPlayer = $AnimationPlayerLower
@onready var animation_player_upper: AnimationPlayer = $AnimationPlayerUpper
@onready var camera: Camera2D = $Camera2D
@export var velocity_camera: float = 600.0
@export var limit_left: float = -400.0
@export var limit_right: float = 400.0

func _physics_process(delta: float) -> void:
	var x_input = Input.get_axis("ui_left", "ui_right")
	
	if not is_on_floor():
		velocity.y += 980 * delta
	
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y -= 400
	
	velocity.x = x_input * 80
	
	if(x_input == 0):
		animation_player_upper.play("idle")
		animation_player_lower.play("idle")
	else:
		anchor.scale.x = sign(x_input)
		animation_player_upper.play("run")
		animation_player_lower.play("run")
	
	if not is_on_floor(): #block jump in a
		animation_player_upper.play("jump")
		animation_player_lower.play("jump")
	move_and_slide()
	
func _process(delta: float) -> void:
	if Input.get_connected_joypads().size() > 0:
		var camera_input_x = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
		var camera_input_y = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
		
		if velocity.x == 0:
			if abs(camera_input_x) > 0.2 or abs(camera_input_y) > 0.2:
				var target_offset_x = camera_input_x * 100.0 #limit distance
				var target_offset_y = camera_input_y * 60.0
				camera.offset.x = lerp(camera.offset.x, target_offset_x, 5 * delta)
				camera.offset.y = lerp(camera.offset.y, target_offset_y, 5 * delta)
			else:  # reset camera 
				camera.offset.x = lerp(camera.offset.x, 0.0, 3.0 * delta)
				camera.offset.y = lerp(camera.offset.y, 0.0, 3.0 * delta) 
