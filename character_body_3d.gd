extends CharacterBody3D

# --- AYARLAR ---
@export var SPEED : float = 7.0
@export var JUMP_VELOCITY : float = 4.5
@export var MOUSE_SENSITIVITY : float = 0.002

# --- DÜĞÜMLER ---
# Sahne ağacında 'Neck' ve onun içinde 'Camera3D' olmalı
@onready var neck := $Neck
@onready var camera := $Neck/Camera3D

func _ready():
	# Fareyi oyun içine hapset
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	# Fare hareketi ile bakış kontrolü
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Sağa-Sola bakış (Karakterin gövdesini döndürür)
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		# Yukarı-Aşağı bakış (Sadece kamerayı/boynu döndürür)
		neck.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		# Takla atmayı önlemek için bakışı sınırla
		neck.rotation.x = clamp(neck.rotation.x, deg_to_rad(-85), deg_to_rad(85))
	
	# ESC tuşuna basınca fareyi serbest bırak (Arayüzde işlem yapabilmek için)
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Oyun ekranına tıklandığında fareyi tekrar hapset
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	# Yerçekimi Uygula
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Zıplama Kontrolü
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Hareket Girdilerini Al (WASD için Input Map ayarı gerektirir)
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	# Kameranın baktığı yöne göre ileri-geri git
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		# Dururken yumuşak duruş yap (move_toward artık hata vermez)
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# Hareketi uygula
	move_and_slide()
