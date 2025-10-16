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
# Botón de cambio de contraseña - puede no existir en todas las escenas
var _btnPasswordChange

var _gameContext:GameContext
var _currentPanel:Node
var _options_window 
var _skills_window
var _password_change_window
var _guild_foundation_window
var _stats_window

var _user_weapon_slot:int
var _user_shield_slot:int
var _user_helmet_slot:int
var _user_armor_slot:int

func _ready() -> void:
	_btnOptions.pressed.connect(Callable(self, "_on_btn_options_pressed"))
	_btnSkills.pressed.connect(Callable(self, "_on_btn_skills_pressed"))
	_btnStadistics.pressed.connect(Callable(self, "_on_btn_stadistics_pressed"))
	
	# Intentar obtener el botón de cambio de contraseña si existe
	_btnPasswordChange = get_node_or_null("Buttons-Misc/btnPasswordChange")
	if _btnPasswordChange:
		_btnPasswordChange.pressed.connect(Callable(self, "_on_btn_password_change_pressed"))
		_btnPasswordChange.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	_btnOptions.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_btnSkills.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_btnStadistics.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

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
	if event.is_action_pressed("ToggleResuscitationSafe"):
		GameProtocol.WriteResuscitationToggle()
	
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
		ShowConsoleMessage("No puedes entrar en meditación, tu maná ya está completo.", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
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
		_guild_foundation_window.form_submitted.connect(_on_guild_foundation_submitted)
		add_child(_guild_foundation_window)
	_guild_foundation_window.show_window()

# Maneja el envío del formulario de fundación de clan
func _on_guild_foundation_submitted(clan_name: String, clan_abbreviation: String, url: String, description: String) -> void:
	# Validar que el nombre del clan no esté vacío
	if clan_name.strip_edges().is_empty():
		ShowConsoleMessage("¡El nombre del clan no puede estar vacío!", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
		
	# Validar la abreviatura (3-5 letras mayúsculas)
	if clan_abbreviation.length() < 3 or clan_abbreviation.length() > 5:
		ShowConsoleMessage("La abreviatura debe tener entre 3 y 5 letras mayúsculas.", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
		
	if not clan_abbreviation.is_valid_identifier():
		ShowConsoleMessage("La abreviatura solo puede contener letras mayúsculas.", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	
	ShowConsoleMessage("¡Solicitud de fundación de clan enviada al consejo real!", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])

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
