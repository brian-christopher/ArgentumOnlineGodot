extends PanelContainer
class_name InventorySlot

signal pressed
signal double_clicked
signal drag_started(from_index: int)
   
var index:int = -1
var _item_icon: Texture2D = null
var _item_quantity: int = 0
var _item_name: String = ""
var _last_click_time: float = 0.0

# Tooltip global compartido entre todos los slots
static var _shared_tooltip: InventoryTooltip = null
static var _tooltip_layer: CanvasLayer = null

const DOUBLE_CLICK_TIME: float = 0.5
  
func SetQuantity(quantity:int) -> void:
	_item_quantity = quantity
	%Quantity.text = str(quantity) if quantity > 1 else ""
	
func SetIcon(texture:Texture2D) -> void:
	_item_icon = texture
	$Icon.texture = texture
	
func SetEquipped(equipped:bool) -> void:
	%Equipped.visible = equipped
	
func SetSelected(selected:bool) -> void:
	%Selected.visible = selected

func SetItemName(item_name: String) -> void:
	_item_name = item_name

func _create_shared_tooltip() -> void:
	if _shared_tooltip == null:
		print("[Tooltip] Creando tooltip global compartido...")
		
		# Crear CanvasLayer dedicado para el tooltip (siempre encima de todo)
		if _tooltip_layer == null:
			_tooltip_layer = CanvasLayer.new()
			_tooltip_layer.layer = 100  # Capa muy alta para estar encima de todo
			_tooltip_layer.name = "TooltipLayer"
			get_tree().current_scene.add_child(_tooltip_layer)
			print("[Tooltip] CanvasLayer creado con layer=", _tooltip_layer.layer)
		
		var tooltip_scene = preload("res://ui/hub/inventory_tooltip.tscn")
		_shared_tooltip = tooltip_scene.instantiate() as InventoryTooltip
		_tooltip_layer.add_child(_shared_tooltip)
		print("[Tooltip] Tooltip global agregado al CanvasLayer: ", _shared_tooltip)

func _show_tooltip() -> void:
	if _item_name != "":
		print("[Tooltip] Mostrando tooltip para: ", _item_name)
		_create_shared_tooltip()
		_shared_tooltip.set_item_info(_item_name, _item_quantity)
		print("[Tooltip] CanvasLayer layer: ", _tooltip_layer.layer)
		_shared_tooltip.show_tooltip(self)
		print("[Tooltip] Tooltip visible: ", _shared_tooltip.visible)
		print("[Tooltip] Tooltip z_index: ", _shared_tooltip.z_index)
	else:
		print("[Tooltip] No se muestra tooltip - nombre vacío")

func _hide_tooltip() -> void:
	if _shared_tooltip != null:
		print("[Tooltip] Ocultando tooltip global")
		_shared_tooltip.hide_tooltip()

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	print("[Tooltip] Mouse entró en slot con item: ", _item_name)
	_show_tooltip()

func _on_mouse_exited() -> void:
	print("[Tooltip] Mouse salió de slot con item: ", _item_name)
	_hide_tooltip()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		# Click izquierdo para selección o doble clic para usar
		if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
			var current_time = Time.get_ticks_msec() / 1000.0  # Convertir a segundos
			
			if current_time - _last_click_time < DOUBLE_CLICK_TIME:
				# Es doble clic
				double_clicked.emit()
				_last_click_time = 0.0  # Resetear para evitar triples clics
			else:
				# Es clic simple - solo selección
				pressed.emit()
				_last_click_time = current_time
				
		# Click derecho para drag and drop
		elif event.pressed && event.button_index == MOUSE_BUTTON_RIGHT:
			if _item_icon != null:
				drag_started.emit(index)
				var preview = _create_preview()
				force_drag({"from_index": index}, preview)

func _create_preview() -> Control:
	# Crear un contenedor para centrar el icono
	var container = Control.new()
	container.custom_minimum_size = Vector2(32, 32)
	
	var preview = TextureRect.new()
	preview.texture = _item_icon
	preview.custom_minimum_size = Vector2(32, 32)
	preview.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	preview.modulate = Color(1, 1, 1, 0.7)
	# Centrar el preview en el contenedor
	preview.position = Vector2(-16, -16)  # Offset para centrar (mitad del tamaño)
	container.add_child(preview)
	
	if _item_quantity > 1:
		var label = Label.new()
		label.text = str(_item_quantity)
		label.position = Vector2(-14, 0)  # Ajustar posición relativa al centro
		container.add_child(label)
	
	return container

# Aceptar drops para evitar el cursor de prohibido
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if typeof(data) == TYPE_DICTIONARY:
		if data.has("from_index"):
			return true  # Siempre aceptar para evitar el cursor prohibido
	return false

func _drop_data(_at_position: Vector2, _data: Variant) -> void:
	# No hacer nada aquí, el movimiento se maneja en inventory_container
	pass

			
