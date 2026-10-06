extends Node2D
# next steps: random flipping left/right, occasional idling random?, right click menu to close or pause, persistent memory, dizzy drop anim, dialogue box and lines

var speed = 150
var direction = Vector2(1, 0)

var screen_size = Vector2()
var window_size = Vector2(200, 200)

var idle_timer = 0.0
var is_idling = false

var flip_timer = 4.0

var is_dragging = false
var drag_offset = Vector2()

var hit_counter = 0 # relationship stats?

@onready var animated_sprite = $AnimatedSprite2D
@onready var body = $BodyArea
@onready var head = $HeadArea

func _ready() -> void:
	screen_size = Vector2(DisplayServer.screen_get_size())
	animated_sprite.play("walk")
	head.input_event.connect(_on_head_input)
	body.input_event.connect(_on_body_input)
	animated_sprite.animation_finished.connect(_on_animation_finished)
	
func _physics_process(delta: float) -> void:
	if is_dragging:
		var mouse_pos = Vector2(DisplayServer.mouse_get_position())
		var new_win_pos = mouse_pos - drag_offset
		DisplayServer.window_set_position(Vector2i(new_win_pos))
		return
	if is_idling:
		idle_timer -= delta
		if idle_timer <= 0:
			is_idling = false
			speed = 150
			animated_sprite.play("walk")
		return
	flip_timer -= delta
	if flip_timer <= 0:
		flip_timer = randf_range(3.0, 8.0)
		maybe_flip()
	var window_position = Vector2(DisplayServer.window_get_position())
	window_position += direction * speed * delta
	window_position.x = clamp(window_position.x, 0, screen_size.x - window_size.x)
	window_position.y = clamp(window_position.y, 0, screen_size.y - window_size.y)
	DisplayServer.window_set_position(Vector2i(window_position))
	if window_position.x <= 0 or window_position.x >= screen_size.x - window_size.x:
		direction.x *= -1
		animated_sprite.flip_h = !animated_sprite.flip_h
		maybe_idle()
	if window_position.y <= 0 or window_position.y >= screen_size.y - window_size.y:
		direction.y *= -1
		maybe_idle()
		

		
func maybe_idle():
	if randf() < 0.4:
		is_idling = true
		idle_timer = randf_range(1.0, 3.0)
		var r = randi() % 3
		if r == 0:
			animated_sprite.play("idle")
			speed = 0
			
func _on_body_input(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			var mouse_pos = Vector2(DisplayServer.mouse_get_position())
			var win_pos = Vector2(DisplayServer.window_get_position())
			drag_offset = mouse_pos - win_pos
			animated_sprite.play("dragged")
		else:
			is_dragging = false
			animated_sprite.play("walk")
			speed = 150
			
func _on_head_input(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and event.double_click:
		if event.pressed:
			hit_counter += 1
			animated_sprite.play("ouch")
			speed = 0
		
func _on_animation_finished():
	if animated_sprite.animation == "ouch":
		is_idling = false
		animated_sprite.play("walk")
		speed = 150
		print("hit counter ", hit_counter)
		
func maybe_flip():
	if animated_sprite.animation == "walk" and randf() < 0.4:
			direction.x *= -1
			animated_sprite.flip_h = !animated_sprite.flip_h
			print("flipped")
