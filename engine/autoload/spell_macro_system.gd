extends Node

# Sistema de Macro de Hechizos F7 - Réplica exacta del sistema de VB6
# Basado en el análisis del cliente original de Argentum Online

const INT_MACRO_HECHIS = 2788  # Intervalo del timer en milisegundos (2.788 segundos)

var spell_macro_timer: Timer
var is_macro_active: bool = false
var selected_spell_index: int = -1  # Índice del hechizo seleccionado en hlst

# Referencias a sistemas del juego
var console: Control
var spell_list: Control  # Equivalente a hlst (lista de hechizos)
var hub_controller: CanvasLayer  # Para obtener posición del cursor

func _ready():
	_setup_macro_timer()
	
func _setup_macro_timer():
	spell_macro_timer = Timer.new()
	spell_macro_timer.wait_time = INT_MACRO_HECHIS / 1000.0  # Convertir a segundos
	spell_macro_timer.timeout.connect(_on_macro_timer_tick)
	add_child(spell_macro_timer)

# Función principal - Toggle del macro de hechizos (F7)
func toggle_spell_macro():
	# Verificar si el personaje está muerto
	if not _is_player_alive():
		_show_console_msg("¡¡Estás muerto!!", Color.RED)
		return
	
	# Verificar si hay un hechizo seleccionado
	if not _is_spell_selected():
		_show_console_msg("Debes tener seleccionado el hechizo para activar el auto-lanzar", Color.CYAN)
		return
	
	if is_macro_active:
		_deactivate_spell_macro()
	else:
		_activate_spell_macro()

func _is_player_alive() -> bool:
	# Verificar si el jugador está vivo usando el GameContext
	var game_context = _get_game_context()
	if game_context and game_context.player_stats:
		return game_context.player_stats.is_alive()
	
	# Si no podemos verificar, asumimos que está vivo para no bloquear el sistema
	return true

func _get_game_context():
	# Obtener el GameContext de forma segura
	if Global.has_method("get_game_context"):
		return Global.get_game_context()
	elif Global.get("game_context"):
		return Global.get("game_context")
	return null

func _is_trading() -> bool:
	# Verificar si está comerciando usando el GameContext
	var game_context = _get_game_context()
	if game_context:
		return game_context.trading or game_context.pause
	return false

func _is_spell_selected() -> bool:
	# Equivalente a: If Not hlst.Visible Then
	if not spell_list or not spell_list.visible:
		return false
	
	# Verificar que haya un hechizo seleccionado
	if selected_spell_index < 0:
		return false
	
	# Verificar que el hechizo seleccionado no sea "(None)"
	if spell_list.has_method("get_selected_spell_text"):
		var spell_text = spell_list.get_selected_spell_text()
		if spell_text == "(None)" or spell_text.is_empty():
			return false
	
	return true

func _activate_spell_macro():
	# Activar el timer
	spell_macro_timer.start()
	is_macro_active = true
	
	_show_console_msg("Auto lanzar hechizos activado", Color.GREEN)
	_update_spell_macro_ui(true)

func _deactivate_spell_macro():
	# Desactivar el timer
	spell_macro_timer.stop()
	is_macro_active = false
	
	_show_console_msg("Auto lanzar hechizos desactivado", Color.YELLOW)
	_update_spell_macro_ui(false)

func _on_macro_timer_tick():
	# Réplica exacta del TrainingMacro_Timer de VB6
	
	# Verificar si la lista de hechizos sigue visible
	if not _is_spell_selected():
		_deactivate_spell_macro()
		return
	
	# Verificar si está comerciando
	if _is_trading():
		return
	
	# Verificar si el hechizo seleccionado no es "(None)" y si puede lanzar
	if _can_cast_spell() and _can_cast_spell_timer():
		# Lanzar el hechizo automáticamente en la posición del cursor
		_cast_spell_at_cursor()

func _cast_spell_at_cursor():
	# Lanzar el hechizo automáticamente en la posición del cursor (como en VB6)
	if not hub_controller:
		print("[SpellMacro] ERROR: No hay hub_controller conectado")
		return
	
	# NUEVO: Primero simular clic en el botón lanzar (como en VB6)
	_simulate_cast_button_click()
	
	# Esperar un momento y luego lanzar en la posición del cursor
	await hub_controller.get_tree().create_timer(0.1).timeout
	
	# CORREGIDO: Usar la función pública del hub_controller (misma lógica que DoubleClick)
	var tile_position = hub_controller.get_mouse_tile_position()
	
	if tile_position == Vector2i.ZERO:
		print("[SpellMacro] ERROR: No se pudo obtener posición del mouse")
		return
	
	print("[SpellMacro] Hechizo lanzado automáticamente en tile: ", tile_position)
	
	# Enviar los paquetes para lanzar el hechizo (igual que cuando haces clic manual)
	GameProtocol.WriteCastSpell(selected_spell_index + 1)  # +1 porque VB6 usa base 1
	GameProtocol.WriteWorkLeftClick(tile_position.x, tile_position.y, Enums.Skill.Magia)

func _simulate_cast_button_click():
	# Simular el clic en el botón de lanzar hechizo (como en VB6)
	if spell_list and spell_list.has_method("_on_btn_cast_pressed"):
		spell_list._on_btn_cast_pressed()
		print("[SpellMacro] Simulando clic en botón lanzar")

func _can_cast_spell() -> bool:
	# Verificar que el hechizo seleccionado no sea "(None)"
	if selected_spell_index < 0:
		return false
	
	if spell_list and spell_list.has_method("get_selected_spell_text"):
		var spell_text = spell_list.get_selected_spell_text()
		if spell_text == "(None)" or spell_text.is_empty():
			return false
	
	return true

func _can_cast_spell_timer() -> bool:
	# Verificar el timer de lanzamiento de hechizos
	# Equivalente a MainTimer.Check(TimersIndex.CastSpell, False)
	# Esto depende de tu sistema de timers
	return true  # Simplificado - debes implementar la lógica real

func _handle_work_left_click():
	# Lógica para WorkLeftClick del timer original
	# ConvertCPtoTP(MouseX, MouseY, tx, tY)
	# If UsingSkill = Magia And Not MainTimer.Check(TimersIndex.CastSpell) Then Exit Sub
	# If UsingSkill = Proyectiles And Not MainTimer.Check(TimersIndex.Attack) Then Exit Sub
	# Call WriteWorkLeftClick(tx, tY, UsingSkill)
	# UsingSkill = 0
	pass

func _show_console_msg(message: String, color: Color):
	# Equivalente a ShowConsoleMsg/Call AddtoRichTextBox
	if console:
		# Implementar según tu sistema de consola
		print("[CONSOLE] ", message)
		# console.add_message(message, color)

func _update_spell_macro_ui(active: bool):
	# Equivalente a ControlSM(eSMType.mSpells, True/False)
	# Actualizar la UI para mostrar el estado del macro
	# Esto puede incluir cambiar el color de un icono, mostrar un indicador, etc.
	pass

# Funciones públicas para que otros sistemas puedan interactuar
func set_spell_list(spell_list_control: Control):
	spell_list = spell_list_control

func set_selected_spell_index(index: int):
	selected_spell_index = index

func set_console(console_control: Control):
	console = console_control

# NUEVO: Configurar el hub_controller para acceso al cursor
func set_hub_controller(hub_control: CanvasLayer):
	hub_controller = hub_control

# Función para desactivar el macro automáticamente (como en VB6)
func auto_deactivate_if_needed():
	# Llamada por otros sistemas cuando es necesario desactivar el macro
	# Por ejemplo: al caminar, morir, comerciar, cambiar de mapa, etc.
	if is_macro_active:
		print("[SpellMacro] ¡Macro desactivado porque el personaje caminó!")
		_show_console_msg("Auto lanzar hechizos desactivado (personaje se movió)", Color.YELLOW)
		spell_macro_timer.stop()
		is_macro_active = false
		_update_spell_macro_ui(false)

# Getters para consultar el estado
func is_spell_macro_active() -> bool:
	return is_macro_active

func get_selected_spell() -> int:
	return selected_spell_index
