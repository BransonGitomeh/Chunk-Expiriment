extends KinematicBody2D

const speed = 100
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(_delta):
	var movement := Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		movement += Vector2.UP
	if Input.is_action_pressed("ui_left"):
		movement += Vector2.LEFT
	if Input.is_action_pressed("ui_right"):
		movement += Vector2.RIGHT
	if Input.is_action_pressed("ui_down"):
		movement += Vector2.DOWN
	move_and_slide(movement.normalized() * speed)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
