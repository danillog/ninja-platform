extends CharacterBody2D

@onready var animation_player_lower: AnimationPlayer = $AnimationPlayerLower
@onready var animation_player_upper: AnimationPlayer = $AnimationPlayerUpper

func _physics_process(delta: float) -> void:
	var x_input = Input.get_axis("ui_left", "ui_right")
	
	velocity.x = x_input * 80
	
	if(x_input == 0):
		animation_player_upper.play("idle")
		animation_player_lower.play("idle")
	else:
		animation_player_upper.play("run")
		animation_player_lower.play("run")
	move_and_slide()
