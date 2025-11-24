extends Window
class_name HotkeyConfigWindow

# Ventana de configuración de hotkeys para Argentum Online
# Permite reasignar todas las teclas del juego

signal hotkey_config_changed()

@onready var tab_container: TabContainer = $VBoxContainer/TabContainer
@onready var preset_option: OptionButton = $VBoxContainer/HBoxPresets/OptionButton
@onready var reset_all_button: Button = $VBoxContainer/HBoxPresets/ResetAllButton
@onready var close_button: Button = $VBoxContainer/ButtonsContainer/CloseButton

var hotkey_entries: Dictionary = {}  # action_name -> HotkeyEntry
var current_listening_entry: HotkeyEntry = null

# Clase interna para cada entrada de hotkey
class HotkeyEntry:
	var action_name: String
	var label: Label
	var button: Button
	var current_key: int
	var current_location: int
	var default_key: int
	var default_location: int
	
	func _init(name: String, lbl: Label, btn: Button, curr_key: int, curr_loc: int, def_key: int, def_loc: int):
		action_name = name
		label = lbl
		button = btn
		current_key = curr_key
		current_location = curr_loc
		default_key = def_key
		default_location = def_loc

func _ready():
	title = "Configuración de Teclas"
	size = Vector2i(600, 500)
	min_size = Vector2i(500, 400)
	
	# Configurar como ventana no exclusiva
	exclusive = false
	close_requested.connect(_on_close_requested)
	
	# Conectar señales
	preset_option.item_selected.connect(_on_preset_selected)
	reset_all_button.pressed.connect(_on_reset_all_pressed)
	close_button.pressed.connect(hide)
	
	# Crear pestañas por categoría
	_create_category_tabs()
	
	# Actualizar presets disponibles
	_refresh_preset_list()
	
	# Cargar configuración actual
	_refresh_all_hotkeys()
	
	# Conectar al sistema de hotkeys
	HotkeyConfig.hotkey_changed.connect(_on_hotkey_changed)
	HotkeyConfig.hotkey_reset.connect(_on_hotkey_reset)

func _create_category_tabs():
	var categories = HotkeyConfig.get_all_categories()
	
	for category in categories:
		var scroll_container = ScrollContainer.new()
		scroll_container.name = category
		
		var vbox = VBoxContainer.new()
		vbox.name = "VBox"
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll_container.add_child(vbox)
		
		# Agregar hotkeys de esta categoría
		var hotkeys = HotkeyConfig.get_hotkeys_by_category(category)
		for hotkey in hotkeys:
			_create_hotkey_entry(vbox, hotkey)
		
		tab_container.add_child(scroll_container)

func _create_hotkey_entry(parent: VBoxContainer, hotkey: HotkeyConfig.HotkeyAction):
	var hbox = HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Etiqueta con el nombre de la acción
	var label = Label.new()
	label.text = hotkey.display_name
	label.custom_minimum_size.x = 150
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(label)
	
	# Descripción (tooltip)
	if not hotkey.description.is_empty():
		label.tooltip_text = hotkey.description
	
	# Botón para mostrar la tecla actual
	var button = Button.new()
	button.text = HotkeyConfig.get_key_name(hotkey.current_key, hotkey.current_location)
	button.custom_minimum_size.x = 100
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.toggle_mode = true
	button.toggled.connect(_on_hotkey_button_toggled.bind(hotkey.name))
	hbox.add_child(button)
	
	# Botón para resetear a valor por defecto
	var reset_button = Button.new()
	reset_button.text = "↺"
	reset_button.custom_minimum_size.x = 30
	reset_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	reset_button.pressed.connect(_on_reset_hotkey_pressed.bind(hotkey.name))
	hbox.add_child(reset_button)
	
	parent.add_child(hbox)
	
	# Guardar referencia
	var entry = HotkeyEntry.new(hotkey.name, label, button, hotkey.current_key, hotkey.current_location, hotkey.default_key, hotkey.default_location)
	hotkey_entries[hotkey.name] = entry

func _on_hotkey_button_toggled(pressed: bool, action_name: String):
	var entry = hotkey_entries.get(action_name)
	if not entry:
		return
	
	if pressed:
		# Comenzar a escuchar para nueva tecla
		_start_listening_for_key(entry)
	else:
		# Cancelar escucha
		_stop_listening_for_key()

func _start_listening_for_key(entry: HotkeyEntry):
	# Detener cualquier escucha anterior
	if current_listening_entry:
		current_listening_entry.button.button_pressed = false
	
	current_listening_entry = entry
	entry.button.text = "Presiona una tecla..."
	entry.button.modulate = Color.YELLOW
	
	# Conectar input
	set_process_input(true)

func _stop_listening_for_key():
	if current_listening_entry:
		var hotkey = HotkeyConfig.get_hotkey(current_listening_entry.action_name)
		if hotkey:
			current_listening_entry.button.text = HotkeyConfig.get_key_name(hotkey.current_key, hotkey.current_location)
		current_listening_entry.button.modulate = Color.WHITE
		current_listening_entry.button.button_pressed = false
	
	current_listening_entry = null
	set_process_input(false)

func _input(event: InputEvent):
	if not current_listening_entry:
		return
	
	if event is InputEventKey and event.pressed:
		var key_code = event.keycode
		var location = event.location
		
		# Permitir teclas modificadoras (Ctrl, Alt, Shift, Meta)
		# Incluye tanto versiones izquierdas como derechas
		var modifier_keys = [KEY_CTRL, KEY_ALT, KEY_SHIFT, KEY_META, 
							  0x200000001, 0x200000002, 0x200000003] # Derechos
		
		# Debug: mostrar información de la tecla detectada
		print("Tecla detectada: ", key_code, " | Location: ", location, " | Key label: ", event.key_label)
		
		# Validar tecla
		if not HotkeyConfig.is_key_valid(key_code):
			_show_error_message("Tecla no válida para configurar")
			_stop_listening_for_key()
			return
		
		# Intentar asignar la tecla
		var conflict_info = HotkeyConfig.get_key_conflict_info(key_code, location, current_listening_entry.action_name)
		if conflict_info.is_empty():
			# No hay conflicto, asignar la tecla
			if HotkeyConfig.set_hotkey(current_listening_entry.action_name, key_code, location):
				# Éxito
				hotkey_config_changed.emit()
		else:
			# Hay conflicto, mostrar mensaje simple
			_show_error_message(conflict_info)
		
		_stop_listening_for_key()
		get_viewport().set_input_as_handled()

func _on_reset_hotkey_pressed(action_name: String):
	HotkeyConfig.reset_hotkey(action_name)
	hotkey_config_changed.emit()

func _on_hotkey_changed(action_name: String, key_code: int):
	var entry = hotkey_entries.get(action_name)
	if entry:
		var hotkey = HotkeyConfig.get_hotkey(action_name)
		if hotkey:
			entry.button.text = HotkeyConfig.get_key_name(hotkey.current_key, hotkey.current_location)
			entry.current_key = hotkey.current_key
			entry.current_location = hotkey.current_location

func _on_hotkey_reset(action_name: String):
	var entry = hotkey_entries.get(action_name)
	if entry:
		var hotkey = HotkeyConfig.get_hotkey(action_name)
		if hotkey:
			entry.button.text = HotkeyConfig.get_key_name(hotkey.current_key, hotkey.current_location)
			entry.current_key = hotkey.current_key
			entry.current_location = hotkey.current_location

func _on_preset_selected(index: int):
	match index:
		0: # WASD
			HotkeyConfig.apply_wasd_preset()
		1: # Flechas
			HotkeyConfig.apply_arrow_keys_preset()
	
	_refresh_all_hotkeys()
	hotkey_config_changed.emit()

func _refresh_preset_list():
	preset_option.clear()
	
	# Solo los dos presets básicos
	preset_option.add_item("WASD")
	preset_option.add_item("Flechas")
	
	# Seleccionar el preset actual (por defecto WASD)
	var current_preset = HotkeyConfig.get_current_preset()
	if current_preset == "arrows":
		preset_option.selected = 1
	else:
		preset_option.selected = 0

func _on_reset_all_pressed():
	# Confirmar reset
	var confirm_dialog = ConfirmationDialog.new()
	confirm_dialog.dialog_text = "¿Estás seguro de que deseas restablecer todas las teclas a sus valores por defecto?"
	confirm_dialog.title = "Confirmar Restablecimiento"
	
	# Conectar señal
	confirm_dialog.confirmed.connect(func():
		HotkeyConfig.reset_all_hotkeys()
		_refresh_all_hotkeys()
		hotkey_config_changed.emit()
	)
	
	add_child(confirm_dialog)
	confirm_dialog.popup_centered()

func _refresh_all_hotkeys():
	for action_name in hotkey_entries:
		var hotkey = HotkeyConfig.get_hotkey(action_name)
		if hotkey:
			var entry = hotkey_entries[action_name]
			entry.button.text = HotkeyConfig.get_key_name(hotkey.current_key, hotkey.current_location)
			entry.current_key = hotkey.current_key
			entry.current_location = hotkey.current_location

func _on_close_requested():
	hide()

func _show_error_message(message: String):
	# Crear diálogo de error - SIN timeout
	var error_dialog = AcceptDialog.new()
	error_dialog.dialog_text = message
	error_dialog.title = "Error"
	
	add_child(error_dialog)
	error_dialog.popup_centered()

func _show_success_message(message: String):
	# Crear diálogo de éxito temporal
	var success_dialog = AcceptDialog.new()
	success_dialog.dialog_text = message
	success_dialog.title = "Éxito"
	
	add_child(success_dialog)
	success_dialog.popup_centered()
	
	# Auto-cerrar después de 2 segundos
	var timer = get_tree().create_timer(2.0)
	timer.timeout.connect(func():
		if success_dialog.is_inside_tree():
			success_dialog.queue_free()
	)

# Función pública para mostrar la ventana
func show_hotkey_config():
	popup_centered()
	_refresh_all_hotkeys()
