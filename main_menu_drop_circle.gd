extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var is_off_screen: bool = false

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	is_off_screen = true
	await get_tree().create_timer(3.0).timeout
	
	if is_off_screen:
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	is_off_screen = false
