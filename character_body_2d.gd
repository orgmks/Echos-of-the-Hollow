extends CharacterBody2D

@export var speed := 200.0

@onready var anim = $AnimatedSprite2D
@onready var attack_sprite = $AttackSprite
@onready var hitbox = $Hitbox

var has_knife = false
var is_attacking = false
var last_direction = Vector2.DOWN

func _ready():
	attack_sprite.visible = false

	# 🔥 evitar loop
	var sf = attack_sprite.sprite_frames
	sf.set_animation_loop("attack_up", false)
	sf.set_animation_loop("attack_down", false)
	sf.set_animation_loop("attack_left", false)
	sf.set_animation_loop("attack_right", false)


func _physics_process(delta):

	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction = Vector2.ZERO

	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	if direction != Vector2.ZERO:
		direction = direction.normalized()
		last_direction = direction

	velocity = direction * speed
	move_and_slide()

	update_animation(direction)

	if has_knife and not is_attacking:
		if Input.is_action_just_pressed("shoot_right"):
			attack(Vector2.RIGHT)
		elif Input.is_action_just_pressed("shoot_left"):
			attack(Vector2.LEFT)
		elif Input.is_action_just_pressed("shoot_up"):
			attack(Vector2.UP)
		elif Input.is_action_just_pressed("shoot_down"):
			attack(Vector2.DOWN)


func update_animation(direction):
	if direction == Vector2.ZERO:
		play_idle()
		return

	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			anim.play("walk_right")
		else:
			anim.play("walk_left")
	else:
		if direction.y > 0:
			anim.play("walk_down")
		else:
			anim.play("walk_up")


func play_idle():
	if abs(last_direction.x) > abs(last_direction.y):
		if last_direction.x > 0:
			anim.play("idle_right")
		else:
			anim.play("idle_left")
	else:
		if last_direction.y > 0:
			anim.play("idle_down")
		else:
			anim.play("idle_up")


func attack(dir: Vector2):
	is_attacking = true
	last_direction = dir

	anim.visible = false
	attack_sprite.visible = true

	# 🔥 SOLO CAMBIAMOS ANIMACIÓN (NO POSICIÓN)
	if dir == Vector2.RIGHT:
		attack_sprite.play("attack_right")
	elif dir == Vector2.LEFT:
		attack_sprite.play("attack_left")
	elif dir == Vector2.UP:
		attack_sprite.play("attack_up")
	elif dir == Vector2.DOWN:
		attack_sprite.play("attack_down")

	hitbox.monitoring = true

	await attack_sprite.animation_finished

	anim.visible = true
	attack_sprite.visible = false
	hitbox.monitoring = false
	is_attacking = false


func pickup_knife():
	has_knife = true
	print("✅ Cuchillo recogido")
