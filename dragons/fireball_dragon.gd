extends CharacterBody2D

enum State {
	DEFAULT,
	ATTACK
}

@export var move_speed = 125.0
@export var moving = false
@export var current_state = State.DEFAULT
@export var fireball_attack_time = 2.0

var fireball_scene = preload("res://dragons/fireball.tscn")

var destination_position
var attack_timer = null
var attack_started = false
var attack_finished = false
var active = false

func _ready():
	position = $InitialPosition.position
	$AnimatedSprite2D.play("default")
#	activate(move_speed)

func activate(speed):
	destination_position = $DefaultPosition.position
	moving = true
	active = true
	move_speed = speed

func _physics_process(delta):
	go_to_destination(delta)
	if moving == false and attack_finished and attack_started:
		attack_started = false
		attack_finished = false
#	if moving == false and not attack_started:
#		leave()
#		start_attack()
	move_and_slide()

func go_to_destination(delta):
	if moving:
		var direction = destination_position - position
		var distance = direction.length()
		var movement = direction.normalized() * min(distance, move_speed * delta)
		position += movement
	if position == destination_position:
		moving = false

func start_attack():
	if moving or attack_started:
		print("Cannot attack: dragon is busy")
		return null
	attack_started = true
	destination_position = $FireballAttackPosition.position
	moving = true
	attack_timer = Timer.new()
	attack_timer.set_wait_time(calculate_movement_time() + 100 / move_speed)
	attack_timer.set_one_shot(true)
	attack_timer.timeout.connect(fireball_attack)
	add_child(attack_timer)
	attack_timer.start()

func fireball_attack():
	print("fireball attack")
	for v in [300, 500, 700, 900, 1100]:
		var fireball = fireball_scene.instantiate()
		fireball.init(v)
		fireball.position = position + Vector2(150, -50)
		print(fireball.global_position)
		get_parent().add_child(fireball)
		get_parent().move_child(fireball, 4)
		
	current_state = State.ATTACK
	attack_timer = Timer.new()
	attack_timer.set_wait_time(fireball_attack_time)
	attack_timer.set_one_shot(true)
	attack_timer.timeout.connect(finish_attack)
	add_child(attack_timer)
	attack_timer.start()

func finish_attack():
	destination_position = $DefaultPosition.position
	moving = true
	attack_finished = true
	current_state = State.DEFAULT
	
func calculate_movement_time():
	var direction = destination_position - position
	var distance = direction.length()
	return distance / move_speed

func leave():
	move_speed = 800
	destination_position = $ExitPosition.position
	moving = true

######################################################33

func set_move_speed(new_move_speed):
	move_speed = new_move_speed

func get_move_speed():
	return move_speed


