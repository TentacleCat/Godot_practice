extends Node2D

const SPEED = 60

var direction = 1

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#var velocity = 10;
	if ray_cast_right.is_colliding():
		direction *= -1
		animated_sprite_2d.flip_h = not animated_sprite_2d.flip_h
	if ray_cast_left.is_colliding():
		direction *= -1
		animated_sprite_2d.flip_h = not animated_sprite_2d.flip_h
	position.x += direction * SPEED * delta
