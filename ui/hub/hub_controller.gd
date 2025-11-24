extends CanvasLayer
class_name HubController

# Función para restaurar el cursor al predeterminado
func _restore_default_cursor() -> void:
	if _gameContext.usingSkill != 0:
		Input.set_custom_mouse_cursor(null)
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		print("Cursor restaurado al predeterminado")
		
		# Resetear el estado de la habilidad en uso
		_gameContext.usingSkill = 0

const MerchantPanelScene = preload("uid://b5q8b0u4jmm2b")
const BankPanelScene = preload("uid://c4skiho4j6vjn") 
const OptionsWindowScene = preload("res://ui/hub/options_window.tscn")
const SkillsWindowScene = preload("res://ui/hub/skills_window.tscn")
const PasswordChangeWindowScene = preload("res://ui/hub/password_change_window.tscn")
const GuildFoundationWindowScene = preload("res://ui/hub/guild_foundation_window.tscn")
const StatsWindowScene = preload("res://ui/hub/stats_window.tscn")
const SpellLearnDialogScene = preload("res://ui/hub/spell_learn_dialog.tscn")
const SpawnListWindowScene = preload("res://ui/hub/spawn_list_window.tscn")

@export var _inventoryContainer:InventoryContainer 
@export var _consoleRichTextLabel:RichTextLabel
@export var _consoleInputLineEdit:LineEdit
@export var _camera:Camera2D
@export var _console_max_lines:int = 10
@export var _console_blocked:bool = false

@onready var minimap: Minimap = $Minimap
@onready var spell_list_panel: SpellListPanel = $"Inventory-Spell/SpellListPanel" 

@onready var experience_stat_bar: StatBar = $StatBars/ExperienceStatBar
@onready var stamina_stat_bar: StatBar = $StatBars/StaminaStatBar
@onready var health_stat_bar: StatBar = $StatBars/HealthStatBar
@onready var mana_stat_bar: StatBar = $StatBars/ManaStatBar 
@onready var thirst_stat_bar: StatBar = $StatBars/ThirstStatBar
@onready var hunger_stat_bar: StatBar = $StatBars/HungerStatBar 

@onready var _btnStadistics = get_node("Buttons-Misc/btnStadistics")
@onready var _btnOptions = get_node("Buttons-Misc/btnOptions")
@onready var _btnSkills = get_node("Buttons-Misc/btnSkills")
@onready var _btnGuilds = get_node("Buttons-Misc/btnGuilds")
# Botón de cambio de contraseña - puede no existir en todas las escenas
var _btnPasswordChange

var _gameContext:GameContext
var _currentPanel:Node
var _options_window 
var _skills_window
var _password_change_window
var _guild_foundation_window
var _guild_leader_window
var _guild_admin_window
var _guild_member_window
var _guild_brief_window
var _guild_news_window
var _guild_proposals_window
var _stats_window
var _spawn_list_window

var _user_weapon_slot:int
var _user_shield_slot:int
var _user_helmet_slot:int
var _user_armor_slot:int

func _ready() -> void:
	# Inicializar el sistema de hotkeys
	HotkeyConfig.load_hotkey_config()
	
	# Conectar señales del sistema de hotkeys
	HotkeyConfig.hotkey_changed.connect(_on_hotkey_changed)
	
	# Resto del código existente...
	_btnOptions.pressed.connect(Callable(self, "_on_btn_options_pressed"))
	_btnSkills.pressed.connect(Callable(self, "_on_btn_skills_pressed"))
	_btnStadistics.pressed.connect(Callable(self, "_on_btn_stadistics_pressed"))
	_btnGuilds.pressed.connect(Callable(self, "_on_btn_guilds_pressed"))
	Global.connect("console_font_size_changed", Callable(self, "_on_console_font_size_changed"))
	Global.connect("player_names_visibility_changed", Callable(self, "_on_player_names_visibility_changed"))
	Global.connect("fps_visibility_changed", Callable(self, "_on_fps_visibility_changed"))
	_apply_console_font_size(Global.consoleFontSize)
	
	# Inicializar el sistema de macro de hechizos
	_setup_spell_macro_system()
	
	# Intentar obtener el botón de cambio de contraseña si existe
	_btnPasswordChange = get_node_or_null("Buttons-Misc/btnPasswordChange")
	if _btnPasswordChange:
		_btnPasswordChange.pressed.connect(Callable(self, "_on_btn_password_change_pressed"))
		_btnPasswordChange.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	_btnOptions.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_btnSkills.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_btnStadistics.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_btnGuilds.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func Init(gameContext:GameContext) -> void:
	_gameContext = gameContext
	_inventoryContainer.SetInventory(_gameContext.playerInventory)
	_inventoryContainer.slotPressed.connect(func(_v): 
		_use_object(true))

func ShowConsoleMessage(message:String, fontData:FontData = FontData.new(Color.WHITE)) -> void:
	# Dividimos por líneas para contar correctamente los "\n" recientes
	var parts:Array = message.split("\n")
	for part in parts:
		var line_bbcode = "[color=#%s]%s[/color]" % [fontData.color.to_html(), part]
		if fontData.italic:
			line_bbcode = "[i]%s[/i]" % line_bbcode
		if fontData.bold:
			line_bbcode = "[b]%s[/b]" % line_bbcode
		# Agregamos directamente al RichTextLabel, sin limpiar/redibujar todo
		_consoleRichTextLabel.append_text(line_bbcode + "\n")

	# Si nos pasamos del máximo, eliminamos los párrafos más antiguos del control
	while _consoleRichTextLabel.get_paragraph_count() > _console_max_lines:
		_consoleRichTextLabel.remove_paragraph(0)

	# Desplazar al final para ver lo último (si no está bloqueado por el usuario)
	if !_console_blocked and _consoleRichTextLabel.get_line_count() > 0:
		_consoleRichTextLabel.scroll_to_line(_consoleRichTextLabel.get_line_count() - 1)

func OpenMerchant() -> void:
	var merchantPanel = MerchantPanelScene.instantiate() as MerchantPanel
	_currentPanel = merchantPanel
	add_child(merchantPanel)
	
	merchantPanel.SetMerchantInventory(_gameContext.merchantInventory)
	merchantPanel.SetPlayerInventory(_gameContext.playerInventory)
	_gameContext.trading = true
	
func CloseMerchant() -> void:
	if _currentPanel:
		_currentPanel.queue_free()
	
	_gameContext.trading = false
	
func OpenBank() -> void:
	var bankPanel = BankPanelScene.instantiate() as BankPanel
	_currentPanel = bankPanel
	add_child(bankPanel)
	
	bankPanel.SetBankInventory(_gameContext.bankInventory)
	bankPanel.SetPlayerInventory(_gameContext.playerInventory)
	_gameContext.trading = true

func CloseBank() -> void:
	if _currentPanel:
		_currentPanel.queue_free()
	_gameContext.trading = false
	
func SetBankGold(gold:int) -> void:
	if _currentPanel && _currentPanel is BankPanel:
		_currentPanel.SetBankGold(gold)
		 
func update_agility_label(value:int) -> void:
	%LblAgility.text = str(value)
	
	
func update_strength_label(value:int) -> void:
	%LblStrength.text = str(value)
		

func update_gold_label(value:int) -> void:
	%LblGold.text = str(value)
	

func update_level_label(value:int) -> void:
	%LblLevel.text = str(value)
		

func update_name_label(value:String) -> void:
	%LblName.text = str(value)
	
	
func update_equipment_label(slot:int, item_stack:ItemStack) -> void:
	if item_stack.equipped:
		match item_stack.item.type:
			Enums.eOBJType.eOBJType_otWeapon:
				%LblWeapon.text = "%d/%d" % [item_stack.item.minHit, item_stack.item.maxHit]
				_user_weapon_slot = slot
			
			Enums.eOBJType.eOBJType_otESCUDO:
				%LblShield.text = "%d/%d" % [item_stack.item.minDef, item_stack.item.maxDef]
				_user_shield_slot = slot
			
			Enums.eOBJType.eOBJType_otArmadura:
				%LblArmor.text = "%d/%d" % [item_stack.item.minDef, item_stack.item.maxDef]
				_user_armor_slot = slot
			
			Enums.eOBJType.eOBJType_otCASCO:
				%LblHelmet.text = "%d/%d" % [item_stack.item.minDef, item_stack.item.maxDef]
				_user_helmet_slot = slot 
	else:
		match slot:
			_user_weapon_slot:
				%LblWeapon.text = "0/0"
				_user_weapon_slot = 0
			
			_user_shield_slot:
				%LblShield.text = "0/0"
				_user_shield_slot = 0
			
			_user_armor_slot:
				%LblArmor.text = "0/0"
				_user_armor_slot = 0
			
			_user_helmet_slot:
				%LblHelmet.text = "0/0"
				_user_helmet_slot = 0
	
func _CameraTransformVector(vec:Vector2) -> Vector2:
	return _camera.get_canvas_transform().affine_inverse() * vec

func _on_console_font_size_changed(value:int) -> void:
	_apply_console_font_size(value)

func _on_player_names_visibility_changed(_visible:bool) -> void:
	_apply_name_visibility_to_all_characters()

func _on_fps_visibility_changed(_visible:bool) -> void:
	_apply_fps_visibility()

func _apply_console_font_size(value:int) -> void:
	_consoleRichTextLabel.set("theme_override_font_sizes/normal_font_size", value)
	_consoleRichTextLabel.set("theme_override_font_sizes/bold_font_size", value)
	_consoleRichTextLabel.set("theme_override_font_sizes/italics_font_size", value)
	_consoleRichTextLabel.set("theme_override_font_sizes/bold_italics_font_size", value)

func _HandleMouseInput(event:InputEventMouseButton) -> void:
	var mouse_tile_position = Vector2i((_CameraTransformVector(event.position) / 32.0).ceil()) 
	
	if _gameContext.trading:
		return
	  
	if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
		if event.double_click:
			GameProtocol.WriteDoubleClick(mouse_tile_position.x, mouse_tile_position.y)
			return
		
		if _gameContext.usingSkill == 0:
			GameProtocol.WriteLeftClick(mouse_tile_position.x, mouse_tile_position.y)
		else:
			if _gameContext.usingSkill == Enums.Skill.Proyectiles:
				if !_gameContext.tick_intervals.request_attack_with_bow():
					_restore_default_cursor()
					ShowConsoleMessage("No puedes lanzar proyectiles tan rápido.", \
					GameAssets.FontDataList[Enums.FontTypeNames.FontType_Talk])
					return
			
			if _gameContext.usingSkill == Enums.Skill.Magia:
				if !_gameContext.tick_intervals.request_cast_spell():
					_restore_default_cursor()
					ShowConsoleMessage("No puedes lanzar hechizos tan rápido.", \
					GameAssets.FontDataList[Enums.FontTypeNames.FontType_Talk])
					return
			
			if _gameContext.usingSkill in [Enums.Skill.Mineria, Enums.Skill.Robar, Enums.Skill.Pesca, Enums.Skill.Talar, Enums.Skill.FundirMetal]:
				if !_gameContext.tick_intervals.request_work():
					_restore_default_cursor()
					return
		
			GameProtocol.WriteWorkLeftClick(mouse_tile_position.x, mouse_tile_position.y, _gameContext.usingSkill)
			# Restaurar el cursor al predeterminado después de hacer click
			_restore_default_cursor()
			print("Cursor restaurado después de hacer click en objetivo")
	
				  
func _handle_key_event(event:InputEventKey) -> void: 
	if event.is_action_pressed("EquipObject"):
		_equip_object()
	if event.is_action_pressed("UseObject"):
		_use_object()
	if event.is_action_pressed("Pickup"):
		_pickup_object()
	if event.is_action_pressed("Attack"):
		_attack()
	if event.is_action_pressed("Hide"):
		_hide()
	if event.is_action_pressed("Meditate"):
		_meditate()
	if event.is_action_pressed("DropObject"):
		_drop_object()
	if event.is_action_pressed("Talk"):
		_talk()
	if event.is_action_pressed("TakeScreenShot"):
		_take_screenshot()
	if event.is_action_pressed("TamAnimal"):
		_tam_animal()
	if event.is_action_pressed("Steal"):
		_steal()
	if event.is_action_pressed("RequestRefresh"):
		_request_position_update()
	if event.is_action_released("ExitGame"):
		_exit_game()
	if event.is_action_pressed("ToggleSafeMode"):
		GameProtocol.WriteSafeToggle()
	if event.is_action_pressed("SpellMacro"):
		SpellMacroSystem.toggle_spell_macro()
	
	# Nuevos hotkeys configurables
	if event.is_action_pressed("ToggleName"):
		_toggle_player_names()
	if event.is_action_pressed("ToggleFPS"):
		_toggle_fps_display()
	
func _unhandled_key_input(event: InputEvent) -> void: 
	if event is InputEventKey:
		_handle_key_event(event)	
	
	
func _OnConsoleInputTextSubmitted(newText: String) -> void:
	if newText.is_empty():
		_consoleInputLineEdit.text = ""
		_consoleInputLineEdit.visible = false
		return
	
	if newText.begins_with("\\"):
		var msg = newText.substr(1).strip_edges()
		var space_idx = msg.find(" ")
		if space_idx > 0:
			var receiver = msg.substr(0, space_idx)
			var body = msg.substr(space_idx + 1).strip_edges()
			if !body.is_empty():
				GameProtocol.WriteWhisper(receiver, body)
			else:
				ShowConsoleMessage("Escribe un mensaje para susurrar. Ej. \\nombre mensaje", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
				return
	elif newText.begins_with("-"):
		var yell_text = newText.substr(1).strip_edges()
		if !yell_text.is_empty():
			GameProtocol.WriteYell(yell_text)
		else:
			ShowConsoleMessage("Formato de susurro inválido. Usa: \\nombre mensaje", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
			return
	else:
		# Procesar comandos de consola o mensaje de chat normal
		if !ConsoleCommandProcessor.process(newText, self, _gameContext):
			GameProtocol.WriteTalk(newText)
	
	# Limpiar y ocultar la consola después de enviar el mensaje
	_consoleInputLineEdit.text = ""
	_consoleInputLineEdit.visible = false

func _equip_object() -> void:
	if !_gameContext.player_stats.is_alive():
		ShowConsoleMessage("¡¡Estás muerto!!", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return  
	
	var slot = _inventoryContainer.GetSelectedSlot()
	if slot == -1 || _gameContext.trading: return

	GameProtocol.WriteEquipItem(slot + 1)

func _use_object(double_click = false) -> void:
	if double_click:
		if !_gameContext.tick_intervals.request_use_item_with_double_click():
			return
	else:
		if !_gameContext.tick_intervals.request_use_item_with_u():
			return
	 
	var slot = _inventoryContainer.GetSelectedSlot() 
	if slot == -1 || _gameContext.trading || _gameContext.pause: return
	
	# Verificar si es un pergamino para mostrar diálogo de confirmación
	var item_stack = _gameContext.playerInventory.GetSlot(slot)
	if item_stack and item_stack.item.type == Enums.eOBJType.eOBJType_otPergaminos:
		_show_spell_learn_dialog(item_stack.item.name, slot + 1)
	else:
		GameProtocol.WriteUseItem(slot + 1)
	
	
func _pickup_object() -> void:
	if !_gameContext.player_stats.is_alive():
		ShowConsoleMessage("¡¡Estás muerto!!", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return  
	GameProtocol.WritePickup()


func _drop_object() -> void:
	if _gameContext.trading:
		return
	
	if !_gameContext.player_stats.is_alive():
		ShowConsoleMessage("¡¡Estás muerto!!", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	if _inventoryContainer.GetSelectedSlot() == -1:
		return
		
	_show_drop_panel(_inventoryContainer.GetSelectedSlot() + 1)

func _attack() -> void:
	if _gameContext.userMeditar || _gameContext.userDescansar:
		return
	
	if _gameContext.tick_intervals.request_attack():
		GameProtocol.WriteAttack()


func _request_position_update() -> void:
	if _gameContext.tick_intervals.request_pos_update():
		GameProtocol.WriteRequestPositionUpdate()


func _exit_game() -> void:
	GameProtocol.WriteQuit()

func _on_hotkey_changed(action_name: String, key_code: int):
	print("[HubController] Hotkey cambiado: ", action_name, " -> ", HotkeyConfig.get_key_name(key_code))
	# Aquí podrías agregar lógica adicional cuando cambian las teclas

func _toggle_player_names():
	# Toggle mostrar/ocultar nombres de jugadores
	Global.show_player_names = not Global.show_player_names
	ShowConsoleMessage("Nombres de personajes " + ("visibles" if Global.show_player_names else "ocultos"), 
		GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])

func _apply_name_visibility_to_all_characters():
	# Buscar el map_container en el árbol de nodos
	var game_screen = get_tree().get_first_node_in_group("game_screen")
	if game_screen:
		var map_container = game_screen.get_node_or_null("MapContainer")
		if map_container:
			map_container.SetAllCharacterNamesVisible(Global.show_player_names)
		else:
			print("No se encontró MapContainer")
	else:
		print("No se encontró game_screen")

func _toggle_fps_display():
	# Toggle mostrar/ocultar FPS
	Global.show_fps_counter = not Global.show_fps_counter
	ShowConsoleMessage("Contador FPS " + ("visible" if Global.show_fps_counter else "oculto"), 
		GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])

func _apply_fps_visibility():
	# Crear o mostrar/ocultar contador FPS
	var fps_label = get_node_or_null("FPSLabel")
	
	if Global.show_fps_counter:
		if not fps_label:
			# Crear label para FPS si no existe
			fps_label = Label.new()
			fps_label.name = "FPSLabel"
			fps_label.position = Vector2(16, 140)
			fps_label.add_theme_font_size_override("font_size", 16)
			fps_label.add_theme_color_override("font_color", Color.WHITE)
			add_child(fps_label)
		
		# Conectar al proceso para actualizar FPS
		if not fps_label.is_connected("tree_exited", _on_fps_tree_exited):
			set_process(true)
	else:
		if fps_label:
			fps_label.queue_free()

func _process(_delta):
	if Global.show_fps_counter:
		var fps_label = get_node_or_null("FPSLabel")
		if fps_label:
			fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

func _on_fps_tree_exited():
	set_process(false)

func _tam_animal() -> void:
	if !_gameContext.player_stats.is_alive():
		ShowConsoleMessage("¡¡Estás muerto!!", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return 
	GameProtocol.WriteWork(Enums.Skill.Domar)
	
	
func _steal() -> void:
	if !_gameContext.player_stats.is_alive():
		ShowConsoleMessage("¡¡Estás muerto!!", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return 
	GameProtocol.WriteWork(Enums.Skill.Robar)

func _talk() -> void:
	if _consoleInputLineEdit.visible:
		return
	if _gameContext.trading:
		return
	
	_consoleInputLineEdit.show()
	_consoleInputLineEdit.grab_focus()
	

func _take_screenshot() -> void: 
	await RenderingServer.frame_post_draw
	
	var viewport = get_viewport()
	var image = viewport.get_texture().get_image()
	
	var now = Time.get_datetime_dict_from_system()
	var date_time = "%04d_%02d_%02d %02d_%02d_%02d" % [now.year, now.month, now.day, now.hour, now.minute, now.second]
	
	var path = "user://screenshots/%s.png" % date_time
	var absolute_path = ProjectSettings.globalize_path("user://screenshots/%s.png" % date_time) 
	
	var meta_data = {
		"type" : "screenshot",
		"path" : absolute_path
	} 
	
	var meta_string = JSON.stringify(meta_data)
	
	if image.save_png(path) == OK:
		ShowConsoleMessage("[url=%s]¡Screen Capturada![/url]" % meta_string, FontData.new(Color.WHITE)) 		
		pass
		
func _hide() -> void:
	if !_gameContext.player_stats.is_alive():
		ShowConsoleMessage("¡¡Estás muerto!!", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return 
		
	GameProtocol.WriteWork(Enums.Skill.Ocultarse)

func _meditate() -> void:
	var stats = _gameContext.player_stats 
	
	if stats.mana == stats.max_mana:
		return
	
	if !stats.is_alive():
		ShowConsoleMessage("¡¡Estás muerto!!", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
		
	GameProtocol.WriteMeditate()

func _on_main_viewport_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_HandleMouseInput(event)
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and Input.is_key_pressed(KEY_SHIFT):
			GameProtocol.WriteWarpMeToTarget()
			get_viewport().set_input_as_handled()
			


func _on_btn_quit_pressed() -> void:
	get_tree().quit()
 

func _on_btn_minimize_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)


func _on_btn_drop_gold_pressed() -> void:
	_show_drop_panel(Consts.Flagoro)
	

func _show_drop_panel(slot:int) -> void:
	var drop_panel = load("uid://c107vd41m3j3s").instantiate() 
	get_parent().add_child(drop_panel)
	
	drop_panel.slot = slot
	drop_panel.popup_centered()


func _on_console_meta_clicked(meta: Variant) -> void:
	var data = JSON.parse_string(meta)
	if data == null: return
	
	if data["type"] == "screenshot":
		OS.shell_open(data["path"])
	
	
func _on_minimap_click(mouse_position: Vector2) -> void:
	if _gameContext.player_map > 0:
		GameProtocol.WriteWarpChar("YO", _gameContext.player_map, int(mouse_position.x), int(mouse_position.y))

func _on_btn_options_pressed() -> void:
	if _options_window == null:
		_options_window = OptionsWindowScene.instantiate()
		add_child(_options_window)
	_options_window.popup_centered()

func _on_btn_skills_pressed() -> void:
	if _skills_window == null:
		_skills_window = SkillsWindowScene.instantiate()
		add_child(_skills_window)
	# Establecer el flag para indicar que estamos esperando las habilidades
	_waiting_for_skills_popup = true
	# Solicitar las habilidades al servidor
	GameProtocol.WriteRequestSkills()

func _on_btn_stadistics_pressed() -> void:
	# Enviar solicitudes para poblar la ventana de estadísticas
	GameProtocol.WriteRequestAtributes()
	GameProtocol.WriteRequestSkills()
	GameProtocol.WriteRequestMiniStats()
	GameProtocol.WriteRequestFame()
	# Mostrar/crear la ventana
	if _stats_window == null:
		_stats_window = StatsWindowScene.instantiate()
		add_child(_stats_window)
	_stats_window.popup_centered()

func _on_btn_password_change_pressed() -> void:
	if _password_change_window == null:
		_password_change_window = PasswordChangeWindowScene.instantiate()
		add_child(_password_change_window)
	_password_change_window.show_window()

var _waiting_for_skills_popup := false

func _show_skills_window(skills:Array) -> void:
	if !_waiting_for_skills_popup:
		return
	_waiting_for_skills_popup = false
	if _skills_window == null:
		_skills_window = SkillsWindowScene.instantiate()
		add_child(_skills_window)
	_skills_window.set_skills(skills)
	_skills_window.popup_centered()

func update_stats_attributes(attrs:Array) -> void:
	if _stats_window == null:
		_stats_window = StatsWindowScene.instantiate()
		add_child(_stats_window)
	_stats_window.set_attributes(attrs)

func update_stats_skills(skills:Array) -> void:
	if _stats_window != null:
		_stats_window.set_skills(skills)

func update_stats_ministats(mini_stats:Dictionary) -> void:
	if _stats_window != null:
		_stats_window.set_ministats(mini_stats)

func update_stats_fame(fame:Dictionary) -> void:
	if _stats_window != null:
		_stats_window.set_fame(fame)

func show_password_change_window() -> void:
	if _password_change_window == null:
		_password_change_window = PasswordChangeWindowScene.instantiate()
		add_child(_password_change_window)
	_password_change_window.show_window(self)

# Muestra la ventana de fundación de clan
func show_guild_foundation_window() -> void:
	if _guild_foundation_window == null:
		_guild_foundation_window = GuildFoundationWindowScene.instantiate()
		_guild_foundation_window.next_pressed.connect(_on_guild_foundation_next)
		add_child(_guild_foundation_window)
	_guild_foundation_window.show_window()

# Maneja cuando se presiona "Siguiente" en el formulario de fundación
func _on_guild_foundation_next(clan_name: String, url: String) -> void:
	# Validar que el nombre del clan no esté vacío
	if clan_name.strip_edges().is_empty():
		ShowConsoleMessage("¡El nombre del clan no puede estar vacío!", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	# Abrir la ventana de detalles (códex y descripción)
	_show_guild_details_window(clan_name, url)

# Muestra la ventana de detalles del clan (códex y descripción)
func _show_guild_details_window(clan_name: String, url: String) -> void:
	var guild_details_scene = load("res://ui/hub/guild_details_window.tscn")
	var guild_details_window = guild_details_scene.instantiate()
	add_child(guild_details_window)
	
	# Configurar la ventana para modo de creación
	guild_details_window.setup_for_creation(clan_name, url)
	guild_details_window.popup_centered()

func _unhandled_input(event: InputEvent) -> void:
	# Si la consola está visible y se presiona ESC, la cerramos
	if event is InputEventKey and event.pressed and !event.echo and event.keycode == KEY_ESCAPE:
		if _consoleInputLineEdit.visible:
			# Marcar el evento como manejado para evitar que se propague
			get_viewport().set_input_as_handled()
			# Limpiar y ocultar la consola
			_consoleInputLineEdit.text = ""
			_consoleInputLineEdit.visible = false
			# Quitar el foco para evitar que el LineEdit capture el siguiente evento
			_consoleInputLineEdit.release_focus()
			# Forzar la actualización del foco
			get_viewport().gui_release_focus()


func _on_console_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_console_blocked = true

func _on_console_mouse_exited() -> void:
	_console_blocked = false

func _on_btn_guilds_pressed() -> void:
	print("[DEBUG] Botón de clanes presionado")
	# Solo solicitar información al servidor
	# El servidor responderá con GuildList, GuildMemberInfo o GuildLeaderInfo según el estado del jugador
	print("[DEBUG] Enviando WriteRequestGuildLeaderInfo...")
	GameProtocol.WriteRequestGuildLeaderInfo()
	ClientInterface.Send(GameProtocol.Flush())
	print("[DEBUG] WriteRequestGuildLeaderInfo enviado y flushed")

## Muestra la ventana de detalles del clan con los datos recibidos
func show_guild_details(data: Dictionary) -> void:
	if _guild_brief_window == null:
		var guild_brief_scene = load("res://ui/hub/guild_brief_window.tscn")
		_guild_brief_window = guild_brief_scene.instantiate()
		add_child(_guild_brief_window)
	_guild_brief_window.set_guild_details(data)
	_guild_brief_window.popup_centered()

## Actualiza los datos de la ventana de líder del clan (cuando el jugador ES líder)
func update_guild_leader_data(guilds: Array, members: Array, news: String, requests: Array) -> void:
	if _guild_leader_window == null:
		var guild_leader_scene = load("res://ui/hub/guild_leader_window.tscn")
		_guild_leader_window = guild_leader_scene.instantiate()
		add_child(_guild_leader_window)
	_guild_leader_window.set_guild_data(guilds, members, news, requests)
	_guild_leader_window.popup_centered()

## Muestra la ventana de noticias del clan
func show_guild_news(news: String, enemies: Array, allies: Array) -> void:
	if _guild_news_window == null:
		var guild_news_scene = load("res://ui/hub/guild_news_window.tscn")
		_guild_news_window = guild_news_scene.instantiate()
		add_child(_guild_news_window)
	_guild_news_window.set_guild_news(news, enemies, allies)
	_guild_news_window.popup_centered()

## Muestra los detalles de una propuesta
func show_offer_details(details: String) -> void:
	var dialog = AcceptDialog.new()
	dialog.dialog_text = details
	dialog.title = "Detalles de la Propuesta"
	add_child(dialog)
	dialog.popup_centered()

## Muestra la lista de propuestas de alianza
func show_alliance_proposals(guilds: Array) -> void:
	if _guild_proposals_window == null:
		var proposals_scene = load("res://ui/hub/guild_proposals_window.tscn")
		_guild_proposals_window = proposals_scene.instantiate()
		add_child(_guild_proposals_window)
	_guild_proposals_window.set_proposals(2, guilds)  # 2 = ALLIANCE
	_guild_proposals_window.popup_centered()

## Muestra la lista de propuestas de paz
func show_peace_proposals(guilds: Array) -> void:
	if _guild_proposals_window == null:
		var proposals_scene = load("res://ui/hub/guild_proposals_window.tscn")
		_guild_proposals_window = proposals_scene.instantiate()
		add_child(_guild_proposals_window)
	_guild_proposals_window.set_proposals(1, guilds)  # 1 = PEACE
	_guild_proposals_window.popup_centered()

## Muestra la lista simple de clanes (cuando el jugador NO tiene clan)
func show_guild_list(guilds: Array) -> void:
	if _guild_admin_window == null:
		var admin_scene = load("res://ui/hub/guild_admin_window.tscn")
		_guild_admin_window = admin_scene.instantiate()
		add_child(_guild_admin_window)
	_guild_admin_window.set_guilds(guilds)
	_guild_admin_window.popup_centered()

## Muestra la ventana de miembro del clan (cuando el jugador tiene clan pero NO es líder)
func show_guild_member_info(guilds: Array, members: Array) -> void:
	if _guild_member_window == null:
		var member_scene = load("res://ui/hub/guild_member_window.tscn")
		_guild_member_window = member_scene.instantiate()
		add_child(_guild_member_window)
	_guild_member_window.set_guild_data(guilds, members)
	_guild_member_window.popup_centered()

## Muestra la ventana de entrenar con lista de criaturas invocables
func show_spawn_list(creatures: Array[String]) -> void:
	if _spawn_list_window == null:
		_spawn_list_window = SpawnListWindowScene.instantiate()
		add_child(_spawn_list_window)
	_spawn_list_window.set_creatures(creatures)
	_spawn_list_window.popup_centered()

## Configura el sistema de macro de hechizos
func _setup_spell_macro_system() -> void:
	# Conectar la consola al sistema de macro
	SpellMacroSystem.set_console(_consoleRichTextLabel)
	
	# Conectar la lista de hechizos al sistema de macro
	if spell_list_panel:
		SpellMacroSystem.set_spell_list(spell_list_panel)
		print("[SpellMacroSystem] Lista de hechizos conectada")
	else:
		print("[SpellMacroSystem] ADVERTENCIA: No se encontró spell_list_panel")
	
	# NUEVO: Conectar el hub_controller para acceso al cursor
	SpellMacroSystem.set_hub_controller(self)
	print("[SpellMacroSystem] HubController conectado para cursor")
	
	print("[SpellMacroSystem] Sistema de macro F7 inicializado")

## Obtiene la posición del tile donde está el cursor del mouse
## Esta función es pública para que otros sistemas (como SpellMacroSystem) la usen
func get_mouse_tile_position() -> Vector2i:
	var viewport = get_viewport()
	if not viewport:
		return Vector2i.ZERO
	
	var mouse_pos = viewport.get_mouse_position()
	var mouse_tile_position = Vector2i((_CameraTransformVector(mouse_pos) / 32.0).ceil())
	mouse_tile_position.y =mouse_tile_position.y - 5
	return mouse_tile_position

## Muestra el diálogo de confirmación para aprender hechizos
func _show_spell_learn_dialog(spell_name: String, slot: int) -> void:
	var dialog = SpellLearnDialogScene.instantiate() as SpellLearnDialog
	add_child(dialog)
	
	# Configurar el nombre del hechizo
	dialog.set_spell_name(spell_name)
	
	# Conectar la señal de confirmación
	dialog.spell_learn_confirmed.connect(func(learn: bool):
		if learn:
			GameProtocol.WriteUseItem(slot)
	)
	
	# Mostrar el diálogo centrado
	dialog.popup_centered()
