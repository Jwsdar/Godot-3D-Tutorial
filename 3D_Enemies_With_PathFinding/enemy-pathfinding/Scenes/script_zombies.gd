extends CharacterBody3D

var player = null
var state_machine
const SPEED = 3.0
const ATTACK_RANGE = 2.5

@onready var player_path = get_node("/root/World/Player")

@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree

const JUMP_VELOCITY = 4.5


func _ready():
	player = player_path
	state_machine = anim_tree.get("parameters/playback")


func _physics_process(delta):
	#State Machine
	match state_machine.get_current_node():
		"Run":
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point-global_transform.origin).normalized()*SPEED
			look_at(Vector3(player.global_position.x + velocity.x, global_position.y, player.global_position.z + velocity.z), Vector3.UP)
		"Attack":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			pass

	
	#Looking At Player
	#global_transform.origin.x = global_position.x
	
	
	#Condition States
	anim_tree.set("parameters/conditions/attack", _target_in_range())
	anim_tree.set("parameters/conditions/run", !_target_in_range())
	anim_tree.get("parameters/playback")
	move_and_slide()
	
func _target_in_range():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE
