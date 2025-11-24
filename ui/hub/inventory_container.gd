extends GridContainer
class_name InventoryContainer
const InventorySlotScene = preload("uid://b8q7jv01joc1r")

signal slotPressed(index:int) 
  
var _inventory:Inventory
var _selectedSlot:int = -1
var _dragging_from_slot:int = -1

func GetSelectedSlot() -> int:
	return _selectedSlot

func GetInventory() -> Inventory:
	return _inventory

func SetInventory(inventory:Inventory) -> void:
	_inventory = inventory
	_inventory.slotChanged.connect(_OnSlotChanged)

	for i in _inventory.GetSize():
		var inventorySlot = InventorySlotScene.instantiate() as InventorySlot
		add_child(inventorySlot)
		
		inventorySlot.index = i
		inventorySlot.pressed.connect(_InventorySlotOnPressed.bind(i))
		inventorySlot.double_clicked.connect(_InventorySlotOnDoubleClicked.bind(i))
		inventorySlot.drag_started.connect(_OnDragStarted)
		_OnSlotChanged(i, _inventory.GetSlot(i))

func GetInventorySlot(index:int) -> InventorySlot:
	for child in get_children():
		if child is InventorySlot && child.index == index:
			return child
	return null

func _OnSlotChanged(index:int, itemStack:ItemStack) -> void:
	var inventorySlot = GetInventorySlot(index) 
	if inventorySlot:
		inventorySlot.SetIcon(itemStack.item.icon)
		inventorySlot.SetQuantity(itemStack.quantity)
		inventorySlot.SetEquipped(itemStack.equipped)
		inventorySlot.SetItemName(itemStack.item.name)

func _OnDragStarted(from_index: int) -> void:
	_dragging_from_slot = from_index
	print("[Inventory] Iniciando drag desde slot %d" % from_index)

func _input(event: InputEvent) -> void:
	# Detectar cuando se suelta el click derecho
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_RIGHT:
		if !event.pressed && _dragging_from_slot != -1:
			# Click derecho soltado: encontrar el slot bajo el cursor
			var target_slot = _get_slot_under_mouse()
			if target_slot != -1 && target_slot != _dragging_from_slot:
				print("[Inventory] Soltando item del slot %d en slot %d" % [_dragging_from_slot, target_slot])
				GameProtocol.WriteMoveItem(_dragging_from_slot + 1, target_slot + 1, 0)
			else:
				print("[Inventory] Cancelado - mismo slot o fuera del inventario")
			
			# Simular un click izquierdo para terminar el drag limpiamente
			var fake_click = InputEventMouseButton.new()
			fake_click.button_index = MOUSE_BUTTON_LEFT
			fake_click.pressed = true
			fake_click.position = get_global_mouse_position()
			Input.parse_input_event(fake_click)
			
			fake_click.pressed = false
			Input.parse_input_event(fake_click)
			
			_dragging_from_slot = -1

func _get_slot_under_mouse() -> int:
	var mouse_pos = get_global_mouse_position()
	for child in get_children():
		if child is InventorySlot:
			var rect = Rect2(child.global_position, child.size)
			if rect.has_point(mouse_pos):
				return child.index
	return -1

func _InventorySlotOnPressed(index:int) -> void:
	# Click izquierdo: solo selección visual, no ejecuta acción
	if _selectedSlot != index:
		if GetInventorySlot(_selectedSlot):
			GetInventorySlot(_selectedSlot).SetSelected(false)
		
		GetInventorySlot(index).SetSelected(true)
		_selectedSlot = index
	# Removido: slotPressed.emit(index) - ya no usa automáticamente con un clic

func _InventorySlotOnDoubleClicked(index:int) -> void:
	# Doble clic: usar el item
	_selectedSlot = index
	# Seleccionar visualmente primero
	if GetInventorySlot(_selectedSlot):
		GetInventorySlot(_selectedSlot).SetSelected(true)
	# Emitir señal para usar el item
	slotPressed.emit(index)
