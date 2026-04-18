extends Area2D

@onready var game_manager: Node = %GameManager
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_body_entered(body: Node2D):

	if body is CharacterBody2D:
		print("Coin alındı! ")
		
		if game_manager:
			game_manager.add_point()
		
		animation_player.play("pickup")
