extends CharacterBody3D

@export var SPEED = 3.5
# Sahnede 'player' grubuna dahil olan nesneyi arar
@onready var player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	# Yerçekimi
	if not is_on_floor():
		velocity += get_gravity() * delta

	if player:
		# Oyuncuya doğru yön vektörü
		var direction = (player.global_position - global_position).normalized()
		
		# Sadece X ve Z ekseninde hareket (Y'yi 0 yaparak uçmasını engelliyoruz)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		# İsteğe bağlı: Düşman her zaman oyuncuya baksın (Billboard ayarı Sprite3D'de açıksa gerekmez)
	
	move_and_slide()
