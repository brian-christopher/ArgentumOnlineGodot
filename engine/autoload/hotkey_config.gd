extends Node

# Sistema completo de configuración de hotkeys para Argentum Online
# Permite personalizar todas las teclas del juego con persistencia

signal hotkey_changed(action_name: String, key_code: int)
signal hotkey_reset(action_name: String)

# Estructura de datos para cada hotkey
class HotkeyAction:
	var name: String
	var display_name: String
	var category: String
	var default_key: int
	var current_key: int
	var default_location: int = 0
	var current_location: int = 0
	var description: String
	var is_modifiable: bool = true
	
	func _init(action_name: String, action_display: String, action_category: String, 
			  default_key_code: int, action_desc: String = ""):
		name = action_name
		display_name = action_display
		category = action_category
		default_key = default_key_code
		current_key = default_key_code
		description = action_desc

# Todas las acciones configurables del juego
var hotkey_actions: Dictionary = {}
var config_file_path: String = "user://hotkeys.cfg"

# Categorías para organizar las teclas
const CATEGORIES = {
	"BASICOS": "Básicos",
	"INVENTARIO": "Inventario",
	"HABILIDADES": "Habilidades",
	"SISTEMA": "Sistema"
}

func _ready():
	_initialize_default_hotkeys()
	load_hotkey_config()

func _initialize_default_hotkeys():
	# Básicos (Movimiento + Combate + Comunicación)
	_add_hotkey("ui_up", "Arriba", CATEGORIES.BASICOS, KEY_W, "Mover hacia arriba")
	_add_hotkey("ui_down", "Abajo", CATEGORIES.BASICOS, KEY_S, "Mover hacia abajo")
	_add_hotkey("ui_left", "Izquierda", CATEGORIES.BASICOS, KEY_A, "Mover hacia izquierda")
	_add_hotkey("ui_right", "Derecha", CATEGORIES.BASICOS, KEY_D, "Mover hacia derecha")
	_add_hotkey("Attack", "Atacar", CATEGORIES.BASICOS, KEY_SPACE, "Atacar objetivo")
	_add_hotkey("AttackGamepad", "Atacar Gamepad", CATEGORIES.BASICOS, JOY_BUTTON_A, "Atacar con gamepad")
	_add_hotkey("Talk", "Hablar", CATEGORIES.BASICOS, KEY_ENTER, "Abrir chat para hablar")
	_add_hotkey("TalkNumpad", "Hablar (Numpad)", CATEGORIES.BASICOS, KEY_KP_ENTER, "Abrir chat con Enter numérico")
	_add_hotkey("TalkWithGuild", "Hablar Clan", CATEGORIES.BASICOS, KEY_F1, "Hablar con el clan")
	
	# Inventario (Usar, Equipar, Tirar + Recoger, Domar, Robar)
	_add_hotkey("UseObject", "Usar Objeto", CATEGORIES.INVENTARIO, KEY_U, "Usar objeto del inventario")
	_add_hotkey("EquipObject", "Equipar Objeto", CATEGORIES.INVENTARIO, KEY_E, "Equipar objeto del inventario")
	_add_hotkey("DropObject", "Tirar Objeto", CATEGORIES.INVENTARIO, KEY_T, "Tirar objeto al suelo")
	_add_hotkey("Pickup", "Recoger", CATEGORIES.INVENTARIO, KEY_Q, "Recoger objeto del suelo")
	_add_hotkey("TamAnimal", "Domar Animal", CATEGORIES.INVENTARIO, KEY_D, "Domar animal")
	_add_hotkey("Steal", "Robar", CATEGORIES.INVENTARIO, KEY_R, "Robar a otro jugador")
	
	# Habilidades
	_add_hotkey("Meditate", "Meditar", CATEGORIES.HABILIDADES, KEY_F5, "Meditar para recuperar maná")
	_add_hotkey("Hide", "Ocultarse", CATEGORIES.HABILIDADES, KEY_O, "Ocultarse en las sombras")
	_add_hotkey("RequestRefresh", "Refrescar", CATEGORIES.HABILIDADES, KEY_L, "Refrescar estadísticas")
	_add_hotkey("SpellMacro", "Macro Hechizos", CATEGORIES.HABILIDADES, KEY_F7, "Activar/desactivar auto-lanzar hechizos")
	_add_hotkey("ToggleSafeMode", "Modo Seguro", CATEGORIES.HABILIDADES, KEY_ASTERISK, "Alternar modo seguro")
	_add_hotkey("ToggleResuscitationSafe", "Seguro Resurrección", CATEGORIES.HABILIDADES, KEY_F6, "Alternar seguro de resurrección")
	
	# Sistema
	_add_hotkey("ToggleName", "Mostrar Nombres", CATEGORIES.SISTEMA, KEY_F2, "Mostrar/ocultar nombres de jugadores")
	_add_hotkey("ToggleFPS", "Mostrar FPS", CATEGORIES.SISTEMA, KEY_F3, "Mostrar/ocultar FPS")
	_add_hotkey("ExitGame", "Salir", CATEGORIES.SISTEMA, KEY_ESCAPE, "Salir del juego")
	_add_hotkey("TakeScreenShot", "Captura", CATEGORIES.SISTEMA, KEY_F9, "Tomar captura de pantalla")
	
func _add_hotkey(action_name: String, display_name: String, category: String, 
				 default_key: int, description: String = ""):
	var hotkey = HotkeyAction.new(action_name, display_name, category, default_key, description)
	hotkey_actions[action_name] = hotkey

# Funciones públicas para gestión de hotkeys
func get_hotkey(action_name: String) -> HotkeyAction:
	return hotkey_actions.get(action_name, null)

func get_all_hotkeys() -> Dictionary:
	return hotkey_actions

func get_hotkeys_by_category(category: String) -> Array[HotkeyAction]:
	var result: Array[HotkeyAction] = []
	for hotkey in hotkey_actions.values():
		if hotkey.category == category:
			result.append(hotkey)
	return result

func get_all_categories() -> Array[String]:
	var categories: Array[String] = []
	for hotkey in hotkey_actions.values():
		if hotkey.category not in categories:
			categories.append(hotkey.category)
	return categories

func set_hotkey(action_name: String, key_code: int, location: int = 0) -> bool:
	var hotkey = hotkey_actions.get(action_name)
	if not hotkey or not hotkey.is_modifiable:
		return false
	
	# Verificar que la tecla no esté en uso por otra acción
	var conflicting_action = _get_key_conflict(key_code, location, action_name)
	if conflicting_action != "":
		return false
	
	hotkey.current_key = key_code
	hotkey.current_location = location
	_update_input_map(action_name, key_code, location)
	hotkey_changed.emit(action_name, key_code)
	save_hotkey_config()
	return true

func _get_key_conflict(key_code: int, location: int, exclude_action: String) -> String:
	# Devuelve el nombre de la acción que usa esta tecla, o vacío si no hay conflicto
	for action_name in hotkey_actions:
		if action_name != exclude_action:
			var hotkey = hotkey_actions[action_name]
			# Para teclas modificadoras, verificamos tanto keycode como location
			if hotkey.current_key == key_code:
				# Si es una tecla modificadora, el location debe ser diferente para evitar conflicto
				if key_code in [KEY_CTRL, KEY_ALT, KEY_SHIFT, KEY_META]:
					if hotkey.current_location != location:
						continue  # No hay conflicto si el location es diferente
				return hotkey.display_name
	return ""

func get_key_conflict_info(key_code: int, location: int, exclude_action: String) -> String:
	# Devuelve información detallada sobre el conflicto
	var conflicting_action = _get_key_conflict(key_code, location, exclude_action)
	if conflicting_action != "":
		return "La tecla ya está siendo usada por: " + conflicting_action
	return ""

func _is_key_already_used(key_code: int, exclude_action: String) -> bool:
	for action_name in hotkey_actions:
		if action_name != exclude_action:
			var hotkey = hotkey_actions[action_name]
			if hotkey.current_key == key_code:
				return true
	return false

func _update_input_map(action_name: String, key_code: int, location: int = 0):
	# Actualizar el InputMap de Godot dinámicamente
	InputMap.action_erase_events(action_name)
	
	var event = InputEventKey.new()
	event.keycode = key_code
	event.location = location
	event.pressed = true
	
	InputMap.action_add_event(action_name, event)

func reset_hotkey(action_name: String) -> bool:
	var hotkey = hotkey_actions.get(action_name)
	if not hotkey:
		return false
	
	hotkey.current_key = hotkey.default_key
	hotkey.current_location = hotkey.default_location
	_update_input_map(action_name, hotkey.default_key, hotkey.default_location)
	hotkey_reset.emit(action_name)
	save_hotkey_config()
	return true

func reset_all_hotkeys():
	for hotkey in hotkey_actions.values():
		hotkey.current_key = hotkey.default_key
		hotkey.current_location = hotkey.default_location
		_update_input_map(hotkey.name, hotkey.default_key, hotkey.default_location)
	save_hotkey_config()

# Presets populares
func apply_wasd_preset():
	var preset_config = {
		"ui_up": KEY_W,
		"ui_down": KEY_S,
		"ui_left": KEY_A,
		"ui_right": KEY_D,
		"Attack": KEY_SPACE,
		"AttackGamepad": JOY_BUTTON_A,
		"Talk": KEY_ENTER,
		"TalkNumpad": KEY_KP_ENTER,
		"TalkWithGuild": KEY_DELETE,
		"UseObject": KEY_U,
		"EquipObject": KEY_E,
		"DropObject": KEY_T,
		"Pickup": KEY_U,
		"TamAnimal": KEY_J,
		"Steal": KEY_R,
		"Meditate": KEY_F6,
		"Hide": KEY_O,
		"RequestRefresh": KEY_L,
		"SpellMacro": KEY_F7,
		"ToggleSafeMode": KEY_ASTERISK,
		"ToggleResuscitationSafe": KEY_END,
		"ToggleName": KEY_N, # ?
		"ToggleFPS": KEY_F3, # ?
		"ExitGame": KEY_F12,
		"TakeScreenShot": KEY_F2, # ?
	}
	_apply_preset_config(preset_config)
	save_current_preset("wasd")

func apply_arrow_keys_preset():
	var preset_config = {
		"ui_up": KEY_UP,
		"ui_down": KEY_DOWN,
		"ui_left": KEY_LEFT,
		"ui_right": KEY_RIGHT,
		"Attack": KEY_CTRL,
		"AttackGamepad": JOY_BUTTON_A,
		"Talk": KEY_ENTER,
		"TalkNumpad": KEY_KP_ENTER,
		"TalkWithGuild": KEY_DELETE,
		"UseObject": KEY_U,
		"EquipObject": KEY_E,
		"DropObject": KEY_T,
		"Pickup": KEY_A,
		"TamAnimal": KEY_D,
		"Steal": KEY_R,
		"Meditate": KEY_F6,
		"Hide": KEY_O,
		"RequestRefresh": KEY_L,
		"SpellMacro": KEY_F7,
		"ToggleSafeMode": KEY_ASTERISK,
		"ToggleResuscitationSafe": KEY_END,
		"ToggleName": KEY_N, # ?
		"ToggleFPS": KEY_F3, # ?
		"ExitGame": KEY_F12,
		"TakeScreenShot": KEY_F2, # ?
	}
	_apply_preset_config(preset_config)
	save_current_preset("arrows")

func _apply_preset_config(config: Dictionary):
	# Aplicar configuración completa sin validación para presets
	for action_name in config:
		var hotkey = hotkey_actions.get(action_name)
		if hotkey:
			hotkey.current_key = config[action_name]
			_update_input_map(action_name, config[action_name])
	
	save_hotkey_config()
	hotkey_changed.emit("preset_applied", 0)  # Señal general

# Sistema de presets personalizados
var custom_presets: Dictionary = {}
var current_preset_name: String = ""

func save_custom_preset(name: String) -> bool:
	if name.is_empty():
		return false
	
	var preset_data = {}
	for action_name in hotkey_actions:
		var hotkey = hotkey_actions[action_name]
		preset_data[action_name] = hotkey.current_key
	
	custom_presets[name] = preset_data
	save_presets_to_file()
	return true

func load_custom_preset(name: String) -> bool:
	var preset_data = custom_presets.get(name, {})
	if preset_data.is_empty():
		return false
	
	_apply_preset_config(preset_data)
	current_preset_name = name
	save_current_preset(name)
	return true

func delete_custom_preset(name: String) -> bool:
	if custom_presets.erase(name):
		save_presets_to_file()
		return true
	return false

func get_custom_presets() -> Array[String]:
	var preset_names: Array[String] = []
	for preset_name in custom_presets.keys():
		preset_names.append(preset_name)
	return preset_names

func save_current_preset(preset_name: String):
	current_preset_name = preset_name
	var config = ConfigFile.new()
	config.load(config_file_path)
	config.set_value("presets", "current", preset_name)
	config.save(config_file_path)

func get_current_preset() -> String:
	var config = ConfigFile.new()
	if config.load(config_file_path) == OK:
		return config.get_value("presets", "current", "")
	return ""

func save_presets_to_file():
	var config = ConfigFile.new()
	config.load(config_file_path)
	
	# Guardar presets personalizados
	config.set_value("presets", "custom", custom_presets)
	
	# Guardar preset actual
	if not current_preset_name.is_empty():
		config.set_value("presets", "current", current_preset_name)
	
	config.save(config_file_path)

func load_presets_from_file():
	var config = ConfigFile.new()
	if config.load(config_file_path) != OK:
		return
	
	# Cargar presets personalizados
	custom_presets = config.get_value("presets", "custom", {})
	
	# Cargar preset actual
	current_preset_name = config.get_value("presets", "current", "")

# Persistencia
func save_hotkey_config():
	var config = ConfigFile.new()
	
	for action_name in hotkey_actions:
		var hotkey = hotkey_actions[action_name]
		config.set_value("hotkeys", action_name, hotkey.current_key)
		config.set_value("hotkeys_locations", action_name, hotkey.current_location)
	
	config.save(config_file_path)

func load_hotkey_config():
	var config = ConfigFile.new()
	
	if not FileAccess.file_exists(config_file_path):
		# Si no existe, crear configuración por defecto
		save_hotkey_config()
		return
	
	var error = config.load(config_file_path)
	if error != OK:
		print("[HotkeyConfig] Error cargando configuración: ", error)
		return
	
	# Cargar hotkeys individuales
	for action_name in hotkey_actions:
		var saved_key = config.get_value("hotkeys", action_name, null)
		var saved_location = config.get_value("hotkeys_locations", action_name, 0)
		if saved_key != null:
			var hotkey = hotkey_actions[action_name]
			hotkey.current_key = saved_key
			hotkey.current_location = saved_location
			_update_input_map(action_name, saved_key, saved_location)
	
	# Cargar presets personalizados y actual
	load_presets_from_file()

# Utilidades
func get_key_name(key_code: int, location: int = 0) -> String:
	# Teclas especiales diferenciadas por location
	if key_code == KEY_CTRL:
		if location == KEY_LOCATION_RIGHT:
			return "Ctrl Derecho"
		else:
			return "Ctrl Izquierdo"
	elif key_code == KEY_ALT:
		if location == KEY_LOCATION_RIGHT:
			return "Alt Derecho"
		else:
			return "Alt Izquierdo"
	elif key_code == KEY_SHIFT:
		if location == KEY_LOCATION_RIGHT:
			return "Shift Derecho"
		else:
			return "Shift Izquierdo"
	elif key_code == KEY_META:
		if location == KEY_LOCATION_RIGHT:
			return "Meta Derecho"
		else:
			return "Meta Izquierdo"
	
	# Teclas especiales con códigos propios (fallback)
	match key_code:
		0x200000001: return "Ctrl Derecho"
		0x200000002: return "Alt Derecho" 
		0x200000003: return "Shift Derecho"
		KEY_KP_ENTER: return "Enter Numérico"
		JOY_BUTTON_A: return "Botón A (Gamepad)"
		JOY_BUTTON_B: return "Botón B (Gamepad)"
		JOY_BUTTON_X: return "Botón X (Gamepad)"
		JOY_BUTTON_Y: return "Botón Y (Gamepad)"
		JOY_BUTTON_DPAD_LEFT: return "D-Pad Izquierdo"
		JOY_BUTTON_DPAD_RIGHT: return "D-Pad Derecho"
		JOY_BUTTON_DPAD_UP: return "D-Pad Arriba"
		JOY_BUTTON_DPAD_DOWN: return "D-Pad Abajo"
		JOY_BUTTON_LEFT_SHOULDER: return "L1 (Gamepad)"
		JOY_BUTTON_RIGHT_SHOULDER: return "R1 (Gamepad)"
		JOY_BUTTON_LEFT_STICK: return "Stick Izquierdo (Gamepad)"
		JOY_BUTTON_RIGHT_STICK: return "Stick Derecho (Gamepad)"
		KEY_ESCAPE: return "ESC"
		KEY_ENTER: return "ENTER"
		KEY_SPACE: return "ESPACIO"
		KEY_TAB: return "TAB"
		KEY_BACKSPACE: return "RETROCESO"
		KEY_DELETE: return "SUPR"
		KEY_INSERT: return "INSERT"
		KEY_HOME: return "INICIO"
		KEY_END: return "FIN"
		KEY_PAGEUP: return "RE PÁG"
		KEY_PAGEDOWN: return "AV PÁG"
		KEY_PAUSE: return "PAUSA"
		KEY_UP: return "↑"
		KEY_DOWN: return "↓"
		KEY_LEFT: return "←"
		KEY_RIGHT: return "→"
		KEY_F1: return "F1"
		KEY_F2: return "F2"
		KEY_F3: return "F3"
		KEY_F4: return "F4"
		KEY_F5: return "F5"
		KEY_F6: return "F6"
		KEY_F7: return "F7"
		KEY_F8: return "F8"
		KEY_F9: return "F9"
		KEY_F10: return "F10"
		KEY_F11: return "F11"
		KEY_F12: return "F12"
		KEY_ASTERISK: return "*"
		KEY_PLUS: return "+"
		KEY_MINUS: return "-"
		KEY_PERIOD: return "."
		KEY_COMMA: return ","
		KEY_SLASH: return "/"
		KEY_BACKSLASH: return "\\"
		KEY_QUOTELEFT: return "`"
		KEY_BRACKETLEFT: return "["
		KEY_BRACKETRIGHT: return "]"
		KEY_SEMICOLON: return ";"
		KEY_APOSTROPHE: return "'"
		_: return OS.get_keycode_string(key_code)

func is_key_valid(key_code: int) -> bool:
	# Permitir CUALQUIER tecla del teclado y gamepad
	# Solo bloquear teclas que realmente no tienen sentido para acciones
	var forbidden_keys = [
		KEY_CAPSLOCK, KEY_NUMLOCK, KEY_SCROLLLOCK,  # Bloqueos
		KEY_PRINT  # Print Screen (generalmente captura pantalla del sistema)
	]
	
	# Permitir teclas especiales diferenciadas y gamepad
	var special_allowed = [
		0x200000001, 0x200000002, 0x200000003, # Ctrl/Alt/Shift derechos
		KEY_CTRL, KEY_ALT, KEY_SHIFT, KEY_META, # Ctrl/Alt/Shift/META izquierdos
		KEY_KP_ENTER, # Enter numérico
		JOY_BUTTON_A, JOY_BUTTON_B, JOY_BUTTON_X, JOY_BUTTON_Y,
		JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_DPAD_RIGHT, JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_DOWN,
		JOY_BUTTON_LEFT_SHOULDER, JOY_BUTTON_RIGHT_SHOULDER,
		JOY_BUTTON_LEFT_STICK, JOY_BUTTON_RIGHT_STICK
	]
	
	# Permitir TODAS las teclas normales del teclado
	return key_code not in forbidden_keys and (key_code >= 0 or key_code in special_allowed)
