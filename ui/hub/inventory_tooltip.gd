extends Panel
class_name InventoryTooltip

@onready var item_name_label: Label = $MarginContainer/VBox/ItemNameLabel
@onready var quantity_label: Label = $MarginContainer/VBox/QuantityLabel
@onready var _content_container: Control = $MarginContainer

const FADE_DURATION: float = 0.2
const HIDE_DURATION: float = 0.15
var _visibility_tween: Tween = null
var _content_tween: Tween = null
var _current_item_name: String = ""
var _current_quantity: int = 1
var _anchor_control: Control = null

const LINE_HEIGHT: float = 30.0


func _ready() -> void:
	visible = false
	custom_minimum_size = Vector2(200, LINE_HEIGHT)
	modulate.a = 0.0
	_reset_content_visuals()
	set_process(false)
	get_viewport().size_changed.connect(_on_viewport_resized)

func set_item_info(item_name: String, quantity: int = 1) -> void:
	_current_item_name = item_name
	_current_quantity = quantity

	var previous_name := item_name_label.text
	var had_previous_name := previous_name != "" and previous_name != "Nombre del objeto"
	var changed_item := had_previous_name and previous_name != item_name
	_update_labels()
	_update_size()

	if changed_item:
		_animate_item_change()
	else:
		_reset_content_visuals()
	
func _update_labels() -> void:
	item_name_label.text = _current_item_name
	
	if _current_quantity > 1:
		quantity_label.text = "Cantidad: %d" % _current_quantity
		quantity_label.visible = true
	else:
		quantity_label.visible = false

func _update_size() -> void:
	var name_width: float = float(item_name_label.get_minimum_size().x)
	var quantity_width: float = 0.0
	if quantity_label.visible:
		quantity_width = float(quantity_label.get_minimum_size().x)
	var content_width: float = max(name_width, quantity_width)

	var margin_left: float = float(_content_container.get_theme_constant("margin_left"))
	var margin_right: float = float(_content_container.get_theme_constant("margin_right"))
	var margin_top: float = float(_content_container.get_theme_constant("margin_top"))
	var margin_bottom: float = float(_content_container.get_theme_constant("margin_bottom"))

	var final_width: float = max(200.0, content_width + margin_left + margin_right)
	var name_height: float = float(item_name_label.get_minimum_size().y)
	var quantity_height: float = 0.0
	if quantity_label.visible:
		quantity_height = float(quantity_label.get_minimum_size().y) + 2.0  # Reducido de 4.0 a 2.0
	var content_height: float = name_height + quantity_height

	var final_height: float = clamp(content_height + margin_top + margin_bottom, LINE_HEIGHT, LINE_HEIGHT*3)

	size = Vector2(final_width, final_height)

func _reset_content_visuals() -> void:
	_content_container.modulate = Color(1, 1, 1, 1)
	_content_container.scale = Vector2.ONE

func _animate_item_change() -> void:
	if _content_tween:
		_content_tween.kill()
	
	_content_container.modulate = Color(1, 1, 1, 0.0)
	_content_container.scale = Vector2(0.95, 0.95)
	_content_tween = create_tween()
	_content_tween.set_ease(Tween.EASE_OUT)
	_content_tween.set_trans(Tween.TRANS_CUBIC)
	_content_tween.parallel().tween_property(_content_container, "modulate", Color(1, 1, 1, 1), 0.12)
	_content_tween.parallel().tween_property(_content_container, "scale", Vector2.ONE, 0.12)

func show_tooltip(anchor: Control) -> void:
	_anchor_control = anchor
	_update_position()
	var was_visible := visible
	visible = true
	set_process(true)
	
	if not was_visible:
		_reset_content_visuals()
	
	# Cancelar animación anterior si existe
	if _visibility_tween:
		_visibility_tween.kill()
	
	# Animación de entrada suave
	_visibility_tween = create_tween()
	_visibility_tween.set_ease(Tween.EASE_OUT)
	_visibility_tween.set_trans(Tween.TRANS_BACK)
	
	# Pequeña animación de escala + fade
	modulate.a = 0.0
	scale = Vector2(0.8, 0.8)
	_visibility_tween.parallel().tween_property(self, "modulate:a", 1.0, FADE_DURATION)
	_visibility_tween.parallel().tween_property(self, "scale", Vector2(1.0, 1.0), FADE_DURATION * 0.8)
	
func hide_tooltip() -> void:
	set_process(false)
	_anchor_control = null
	
	# Cancelar animación anterior si existe
	if _visibility_tween:
		_visibility_tween.kill()
	
	# Animación de salida suave
	_visibility_tween = create_tween()
	_visibility_tween.set_ease(Tween.EASE_IN)
	_visibility_tween.set_trans(Tween.TRANS_CUBIC)
	
	# Fade out + pequeña escala
	_visibility_tween.parallel().tween_property(self, "modulate:a", 0.0, HIDE_DURATION)
	_visibility_tween.parallel().tween_property(self, "scale", Vector2(0.9, 0.9), HIDE_DURATION)
	_visibility_tween.tween_callback(func():
		visible = false
		scale = Vector2.ONE
		modulate.a = 0.0
	)

func _process(_delta: float) -> void:
	if not visible:
		return
	_update_position()

func _update_position() -> void:
	if _anchor_control == null or not is_instance_valid(_anchor_control):
		return

	var anchor_rect := _anchor_control.get_global_rect()
	var viewport_rect := get_viewport().get_visible_rect()
	var margin := 12.0
	var desired_pos := Vector2(
		anchor_rect.position.x + anchor_rect.size.x + margin,
		anchor_rect.position.y + (anchor_rect.size.y - size.y) * 0.5
	)

	if desired_pos.x + size.x > viewport_rect.size.x - margin:
		desired_pos.x = anchor_rect.position.x - size.x - margin
	if desired_pos.x < margin:
		desired_pos.x = margin
	if desired_pos.y + size.y > viewport_rect.size.y - margin:
		desired_pos.y = viewport_rect.size.y - size.y - margin
	if desired_pos.y < margin:
		desired_pos.y = margin

	position = desired_pos

func _on_viewport_resized() -> void:
	_update_position()
