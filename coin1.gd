extends Area2D
@onready var game_manager: Node = %GameManager




func _on_body_entered(body: Node2D):
	# Sadece ve sadece adı Player olan bir şey girerse işlem yap
	if body.name == "Player":
		print("Coin oyuncu tarafından alındı!")
		game_manager.add_point()
		queue_free()
