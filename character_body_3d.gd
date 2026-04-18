extends CharacterBody3D

# --- AYARLAR ---
@export var SPEED : float = 7.0
@export var JUMP_VELOCITY : float = 4.5
@export var MOUSE_SENSITIVITY : float = 0.002

# --- CAN AYARLARI ---
@export var MAX_HEALTH : float = 100.0
var current_health : float = MAX_HEALTH
var is_dead : bool = false # Ölüm durumunu takip eder

# --- DÜĞÜMLER ---
@onready var neck := $Neck
@onready var camera := $Neck/Camera3D
@onready var damage_overlay = get_node_or_null("CanvasLayer/DamageColor")
@onready var health_bar = get_node_or_null("CanvasLayer/HealthBar")
@onready var death_screen = get_node_or_null("CanvasLayer/DeathScreen")

func _ready():
	add_to_group("player")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	current_health = MAX_HEALTH
	is_dead = false
	
	if health_bar:
		health_bar.max_value = MAX_HEALTH
		health_bar.value = current_health
	
	if death_screen:
		death_screen.visible = false
		
	if damage_overlay:
		damage_overlay.color.a = 0.0

func _input(event):
	# Eğer ölüysek ve R tuşuna basılırsa oyunu yeniden başlat
	if is_dead and event.is_action_pressed("restart_key") or (is_dead and event is InputEventKey and event.keycode == KEY_R):
		get_tree().reload_current_scene()

func take_damage(amount: float):
	if is_dead: return # Zaten ölüysek hasar almayalım
	
	current_health -= amount
	
	if health_bar:
		health_bar.value = current_health
	
	if damage_overlay:
		damage_overlay.color.a = 0.4 
		var tween = create_tween()
		tween.tween_property(damage_overlay, "color:a", 0.0, 0.4)
	
	if current_health <= 0:
		die()

func die():
	is_dead = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if death_screen:
		death_screen.visible = true
	print("Öldün! Yeniden başlamak için R tuşuna bas.")

func _unhandled_input(event: InputEvent) -> void:
	if is_dead: return # Ölüyken etrafa bakma

	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		neck.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		neck.rotation.x = clamp(neck.rotation.x, deg_to_rad(-85), deg_to_rad(85))
	
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	if is_dead: return # Ölüyken hareket etme

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
