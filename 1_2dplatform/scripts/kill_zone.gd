extends Area2D

@onready var timer: Timer = $Timer
#@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
#@onready var player: CharacterBody2D = $"."

func _on_body_entered(body: Node2D) -> void:
	#print("You Died")
	Engine.time_scale = 0.5
	#body.animated_sprite_2d.play("death")
	body.get_node("CollisionShape2D").queue_free()
	timer.start()


func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()
