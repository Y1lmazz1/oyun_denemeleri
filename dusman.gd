extends CharacterBody3D

@export var SPEED = 3.5
@export var DAMAGE = 25.0
@export var ATTACK_COOLDOWN = 1.0 # Saniyede bir vurur

@onready var player = get_tree().get_first_node_in_group("player")
var can_attack = true

func _physics_process(delta: float) -> void:
	# Yerçekimi
	if not is_on_floor():
		velocity += get_gravity() * delta

	if player:
		# Oyuncuyu takip et
		var direction = (player.global_position - global_position).normalized()
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	
	move_and_slide()

# --- Area3D Sinyali Buraya Bağlanmalı ---
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and can_attack:
		if body.has_method("take_damage"):
			body.take_damage(DAMAGE)
			start_cooldown()

func start_cooldown():
	can_attack = false
	await get_tree().create_timer(ATTACK_COOLDOWN).timeout
	can_attack = true
