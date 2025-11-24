extends Node
class_name GameScreen

# Importar comandos de red
const ShowGuildAlignCommand = preload("res://network/commands/ShowGuildAlign.gd")
const ShowGuildFundationFormCommand = preload("res://network/commands/ShowGuildFundationForm.gd")
const Atributes = preload("res://network/commands/Atributes.gd")
const MiniStats = preload("res://network/commands/MiniStats.gd")
const Fame = preload("res://network/commands/Fame.gd")
const GuildList = preload("res://network/commands/GuildList.gd")
const GuildMemberInfo = preload("res://network/commands/GuildMemberInfo.gd")
const GuildLeaderInfo = preload("res://network/commands/GuildLeaderInfo.gd")
const GuildDetails = preload("res://network/commands/GuildDetails.gd")
const GuildNews = preload("res://network/commands/GuildNews.gd")
const OfferDetails = preload("res://network/commands/OfferDetails.gd")
const AllianceProposalsList = preload("res://network/commands/AllianceProposalsList.gd")
const PeaceProposalsList = preload("res://network/commands/PeaceProposalsList.gd")
const TrainerCreatureList = preload("res://network/commands/TrainerCreatureList.gd")

# Cursor personalizado para selección de objetivo
var _crosshair_cursor: Texture2D = null
var _scaled_crosshair_cursor = null
@export var _gameInput:HubController
@export var _gameWorld:GameWorld
@export var _camera:Camera2D

var _gameContext:GameContext = GameContext.new()
var _mainCharacterInstanceId:int = -1
var networkMessages:Array[PackedByteArray]

var _input:Dictionary[String, int] = {
	"ui_left" = Enums.Heading.West,
	"ui_right" = Enums.Heading.East,
	"ui_up" = Enums.Heading.North,
	"ui_down" = Enums.Heading.South,
}
 
func _ready() -> void: 
	ClientInterface.disconnected.connect(_OnDisconnected)
	ClientInterface.dataReceived.connect(_OnDataReceived) 
	
	_gameInput.Init(_gameContext)
	_gameInput.update_name_label(Global.username)
	
	# Cargar el cursor después de que los recursos estén listos
	if FileAccess.file_exists("res://Assets/Cursors/crosshair.png"):
		_crosshair_cursor = load("res://Assets/Cursors/crosshair.png")
		if _crosshair_cursor:
			_scaled_crosshair_cursor = _scale_cursor(_crosshair_cursor, 0.5)  # Ajusta el factor de escala según necesites

# Función para escalar el cursor a un tamaño más pequeño
func _scale_cursor(texture: Texture2D, scale_factor: float) -> Texture2D:
	# Obtener la imagen del cursor
	var image = texture.get_image()
	
	# Calcular el nuevo tamaño
	var original_size = image.get_size()
	var new_size = original_size * scale_factor
	
	# Redimensionar la imagen
	image.resize(int(new_size.x), int(new_size.y), Image.INTERPOLATE_BILINEAR)
	
	# Crear una nueva textura con la imagen redimensionada
	var new_texture = ImageTexture.create_from_image(image)
	
	return new_texture
	 
func _OnDisconnected() -> void:
	var screen = load("uid://cd452cndcck7v").instantiate() 
	ScreenController.SwitchScreen(screen)
	
func _OnDataReceived(data:PackedByteArray) -> void:
	print("[DEBUG] _OnDataReceived - Recibido ", data.size(), " bytes del servidor")
	networkMessages.push_back(data)

func _process(_delta: float) -> void:
	_ProccessMessages()
	_CheckKeys()
	_UpdateCameraPosition()
	_FlushData()
	
func _UpdateCameraPosition() -> void:
	var character = _gameWorld.GetCharacter(_mainCharacterInstanceId)
	if character && _camera:
		_camera.position = character.position

func _CheckKeys() -> void:
	if _gameContext.traveling || _gameContext.mirandoForo ||\
		_gameContext.trading  || _gameContext.pause:
		return
	
	for k in _input:
		if Input.is_action_pressed(k):
			_MovePlayer(_input[k])
			return

func _MovePlayer(heading:int) -> void:
	if heading == Enums.Heading.None:
		return

	var character = _gameWorld.GetCharacter(_mainCharacterInstanceId)
	if character == null || character.isMoving:
		return
		
	var newGridLocation = character.gridPosition + Vector2i(Utils.HeadingToVector(heading))
	if _CanMoveTo(newGridLocation.x, newGridLocation.y) && !_gameContext.userParalizado:
		#TODO 
		#No se porque esto esta asi. Lo unico que logra es que el personaje pegue un salto cuando camina
		#Obligando al usuario a presionar la tecla L(PosUpdate)
		GameProtocol.WriteWalk(heading)
		if !_gameContext.userDescansar && !_gameContext.userMeditar:
			_gameWorld.MoveCharacter(_mainCharacterInstanceId, heading)
	else:
		if character.renderer.heading != heading:
			GameProtocol.WriteChangeHeading(heading)
	
	_gameInput.minimap.update_player_position(character.gridPosition.x, character.gridPosition.y)
	 
func _CanMoveTo(x:int, y:int) -> bool:
	var map = _gameWorld.GetMapContainer()
	
	#Tile Bloqueado?
	if map.GetTile(x - 1, y - 1) & Enums.TileState.Blocked:
		return false
	
	var character = map.GetCharacterAt(x, y)
	var mainCharacter = map.GetCharacter(_mainCharacterInstanceId)
	var playerPos = Vector2i(mainCharacter.gridPosition)
	
	if character:
		if map.GetTile(playerPos.x - 1, playerPos.y - 1) & Enums.TileState.Blocked:
			return false
			
		#Si no es casper, no puede pasar
		if character.renderer.head != Consts.CabezaCasper && character.renderer.body != Consts.CuerpoFragataFantasmal:
			return false
		else:
			#No puedo intercambiar con un casper que este en la orilla (Lado tierra)
			if map.GetTile(playerPos.x - 1, playerPos.y - 1) & Enums.TileState.Water:
				if !bool(map.GetTile(x - 1, y -1) & Enums.TileState.Water):
					return false
			else:
				#No puedo intercambiar con un casper que este en la orilla (Lado agua)
				if map.GetTile(x - 1, y -1) & Enums.TileState.Water:
					return false
			#Los admins no pueden intercambiar pos con caspers cuando estan invisibles
			if mainCharacter.priv > 0 && mainCharacter.priv < 6:
				if mainCharacter.GetCharacterInvisible():
					return false
		 
	if _gameContext.userNavegando != bool(map.GetTile(x - 1, y -1) & Enums.TileState.Water):
		return false
	
	return true

#region Network
func _ProccessMessages() -> void: 
	while !networkMessages.is_empty():
		var data = networkMessages.pop_front()
		_HandleIncomingData(data) 

func _HandleIncomingData(data:PackedByteArray) -> void:
	print("[DEBUG] _HandleIncomingData recibió ", data.size(), " bytes")
	var stream = StreamPeerBuffer.new()
	stream.data_array = data
	
	while stream.get_position() < stream.get_size():
		_HandleOnePacket(stream)

var pcg:Array[String] 

func _HandleOnePacket(stream:StreamPeerBuffer) -> void:
	var packetId = stream.get_u8()
	var pname = ""
	if packetId < Enums.ServerPacketID.keys().size():
		pname = Enums.ServerPacketID.keys()[packetId]
	else:
		pname = "Paquete desconocido"
		print("[DEBUG] Paquete no reconocido recibido. ID: ", packetId, " (0x", "%02X" % packetId, ")")
		return
		
	pcg.append(name)
	match packetId:
		Enums.ServerPacketID.MultiMessage:
			_HandleMultiMessage(MultiMessage.new(stream))
		Enums.ServerPacketID.ChangeInventorySlot:
			_HandleChangeInventorySlot(ChangeInventorySlot.new(stream))
		Enums.ServerPacketID.ChangeSpellSlot:
			_HandleChangeSpellSlot(ChangeSpellSlot.new(stream))
		Enums.ServerPacketID.UserIndexInServer:
			UserIndexInServer.new(stream)
		Enums.ServerPacketID.ChangeMap:
			_HandleChangeMap(ChangeMap.new(stream))
		Enums.ServerPacketID.PlayMIDI:
			_HandlePlayMidi(PlayMidi.new(stream))
		Enums.ServerPacketID.ShowGuildAlign:
			_HandleShowGuildAlign(ShowGuildAlignCommand.from_buffer(stream, self))
		Enums.ServerPacketID.ShowGuildFundationForm:
			_HandleShowGuildFundationForm(ShowGuildFundationFormCommand.from_buffer(stream, self))
		Enums.ServerPacketID.PlayWave:
			_HandlePlayWave(PlayWave.new(stream))
		Enums.ServerPacketID.AreaChanged:
			_HandleAreaChanged(AreaChanged.new(stream))
		Enums.ServerPacketID.ObjectCreate:
			_HandleObjectCreate(ObjectCreate.new(stream))
		Enums.ServerPacketID.ObjectDelete:
			_HandleObjectDelete(ObjectDelete.new(stream))
		Enums.ServerPacketID.BlockPosition:
			_HandleBlockPosition(BlockPosition.new(stream))
		Enums.ServerPacketID.CharacterCreate:
			_HandleCharacterCreate(CharacterCreate.new(stream))
		Enums.ServerPacketID.CharacterMove:
			_HandleCharacterMove(CharacterMove.new(stream))
		Enums.ServerPacketID.SetInvisible:
			_HandleSetInvisible(SetInvisible.new(stream))
		Enums.ServerPacketID.CreateFX:
			_HandleCreateFx(CreateFx.new(stream))
		Enums.ServerPacketID.UserCharIndexInServer:
			_HandleUserCharIndexInServer(UserCharIndexInServer.new(stream))
		Enums.ServerPacketID.UpdateUserStats:
			_HandleUpdateUserStats(UpdateUserStats.new(stream))
		Enums.ServerPacketID.Atributes:
			_HandleAtributes(Atributes.new(stream))
		Enums.ServerPacketID.UpdateHungerAndThirst:
			_HandleUpdateHungerAndThirst(UpdateHungerAndThirst.new(stream))
		Enums.ServerPacketID.UpdateStrenghtAndDexterity:
			_HandleUpdateStrengthAndDexterity(UpdateStrengthAndDexterity.new(stream))
		Enums.ServerPacketID.GuildChat:
			_HandleGuildChat(GuildChat.new(stream))
		Enums.ServerPacketID.SendSkills:
			_HandleSendSkills(SendSkills.new(stream))
		Enums.ServerPacketID.Fame:
			_HandleFame(Fame.new(stream))
		Enums.ServerPacketID.MiniStats:
			_HandleMiniStats(MiniStats.new(stream))
		Enums.ServerPacketID.LevelUp:
			_HandleLevelUp(LevelUp.new(stream))
		Enums.ServerPacketID.Logged:
			_HandleLogged(Logged.new(stream))
		Enums.ServerPacketID.RainToggle:
			pass
		Enums.ServerPacketID.RemoveDialogs:
			_HandleRemoveDialogs()
		Enums.ServerPacketID.UpdateSta:
			_HandleUpdateSta(UpdateSta.new(stream))
		Enums.ServerPacketID.ConsoleMsg:
			_HandleConsoleMessage(ConsoleMessage.new(stream))
		Enums.ServerPacketID.RemoveCharDialog:
			_HandleRemoveCharDialog(RemoveCharDialog.new(stream))
		Enums.ServerPacketID.CharacterRemove:
			_HandleCharacterRemove(CharacterRemove.new(stream))
		Enums.ServerPacketID.UpdateHP:
			_HandleUpdateHP(UpdateHP.new(stream))
		Enums.ServerPacketID.CharacterChange:
			_HandleCharacterChange(CharacterChange.new(stream))
		Enums.ServerPacketID.ForceCharMove:
			_HandleForceCharMove(ForceCharMove.new(stream))
		Enums.ServerPacketID.PosUpdate:
			_HandlePosUpdate(PosUpdate.new(stream))
		Enums.ServerPacketID.UpdateTagAndStatus:
			_HandleUpdateTagAndStatus(UpdateTagAndStatus.new(stream))
		Enums.ServerPacketID.ChatOverHead:
			_HandleChatOverHead(ChatOverHead.new(stream))
		Enums.ServerPacketID.ChangeNPCInventorySlot:
			_HandleChangeNPCInventorySlot(ChangeNPCInventorySlot.new(stream))
		Enums.ServerPacketID.CommerceInit:
			_HandleCommerceInit()
		Enums.ServerPacketID.CommerceEnd:
			_HandleCommerceEnd()
		Enums.ServerPacketID.TradeOK:
			pass
		Enums.ServerPacketID.BankOK:
			pass
		Enums.ServerPacketID.Blind:
			_handle_blind()
		Enums.ServerPacketID.BlindNoMore:
			_handle_blind_no_more()
		Enums.ServerPacketID.RestOK:
			_handle_rest_ok()
		Enums.ServerPacketID.Dumb:
			_handle_dumb()
		Enums.ServerPacketID.DumbNoMore:
			_handle_dumb_no_more()
		Enums.ServerPacketID.UserCommerceInit:
			_handle_user_commerce_init(UserCommerceInit.new(stream))
		Enums.ServerPacketID.UserCommerceEnd:
			_handle_commerce_end()
		Enums.ServerPacketID.UserOfferConfirm:
			_handle_user_offer_confirm()
		Enums.ServerPacketID.CommerceChat:
			_handle_commerce_chat(CommerceChat.new(stream))
		Enums.ServerPacketID.CancelOfferItem:
			_handle_cancel_offer_item(CancelOfferItem.new(stream))
		Enums.ServerPacketID.ParalizeOK:
			_handle_paralize_ok()
		Enums.ServerPacketID.SendNight:
			_handle_send_night(SendNight.new(stream))
		Enums.ServerPacketID.ErrorMsg:
			_handle_error_message(ErrorMsg.new(stream))
		Enums.ServerPacketID.ChangeBankSlot:
			_HandleChangeBankSlot(ChangeBankSlot.new(stream))
		Enums.ServerPacketID.BankInit:
			_HandleBankInit(BankInit.new(stream))
		Enums.ServerPacketID.BankEnd:
			_HandleBankEnd()
		Enums.ServerPacketID.UpdateBankGold:
			_HandleUpdateBankGold(UpdateBankGold.new(stream))
		Enums.ServerPacketID.UpdateGold:
			_HandleUpdateGold(UpdateGold.new(stream))
		Enums.ServerPacketID.UpdateStrenght:
			_HandleUpdateStrenght(UpdateStrenght.new(stream))
		Enums.ServerPacketID.UpdateDexterity:
			_HandleUpdateDexterity(UpdateDexterity.new(stream))
		Enums.ServerPacketID.Pong:
			_HandlePong()
		Enums.ServerPacketID.ShowMessageBox:
			_HandleShowMessageBox(ShowMessageBox.new(stream))
		Enums.ServerPacketID.UpdateExp:
			_HandelUpdateExp(UpdateExp.new(stream))
		Enums.ServerPacketID.MeditateToggle:
			_handle_meditate_toggle()
		Enums.ServerPacketID.UpdateMana:
			_handle_update_mana(UpdateMana.new(stream))
		Enums.ServerPacketID.NavigateToggle:
			_handle_navigate_toggle()
		Enums.ServerPacketID.PauseToggle:
			_handle_pause_toggle()
		Enums.ServerPacketID.StopWorking:
			_handle_stop_working()
		Enums.ServerPacketID.ShowBlacksmithForm:
			_handle_show_blacksmith_form()
		Enums.ServerPacketID.ShowCarpenterForm:
			_handle_show_carpenter_form()
		Enums.ServerPacketID.CarpenterObjects:
			_handle_carpenter_objects(CarpenterObjects.new(stream))
		Enums.ServerPacketID.BlacksmithWeapons:
			_handle_blacksmith_weapons(BlacksmithWeapons.new(stream))
		Enums.ServerPacketID.BlacksmithArmors:
			_handle_blacksmith_armors(BlacksmithArmors.new(stream))
		Enums.ServerPacketID.CharacterChangeNick:
			_handle_character_change_nick(CharacterChangeNick.new(stream))
		Enums.ServerPacketID.GuildList:
			_handle_guild_list(GuildList.new(stream))
		Enums.ServerPacketID.GuildMemberInfo:
			_handle_guild_member_info(GuildMemberInfo.new(stream))
		Enums.ServerPacketID.GuildLeaderInfo:
			print("[DEBUG] Packet GuildLeaderInfo recibido, creando objeto...")
			var guild_leader_info = GuildLeaderInfo.new(stream)
			print("[DEBUG] Objeto GuildLeaderInfo creado, llamando handler...")
			_handle_guild_leader_info(guild_leader_info)
		Enums.ServerPacketID.GuildDetails:
			_handle_guild_details(GuildDetails.new(stream))
		Enums.ServerPacketID.GuildNews:
			_handle_guild_news(GuildNews.new(stream))
		Enums.ServerPacketID.OfferDetails:
			_handle_offer_details(OfferDetails.new(stream))
		Enums.ServerPacketID.AlianceProposalsList:
			_handle_alliance_proposals_list(AllianceProposalsList.new(stream))
		Enums.ServerPacketID.PeaceProposalsList:
			_handle_peace_proposals_list(PeaceProposalsList.new(stream))
		Enums.ServerPacketID.TrainerCreatureList:
			_handle_trainer_creature_list(TrainerCreatureList.new(stream))
		_:
			print(pname)
	

func _handle_character_change_nick(p:CharacterChangeNick) -> void:
	var character = _gameWorld.GetCharacter(p.char_index)
	if character:
		character.SetCharacterName(p.char_name)
	
	
func _handle_user_commerce_init(p:UserCommerceInit) -> void:
	pass


#TODO Completar
func _handle_commerce_end() -> void:
	_gameContext.trading = false


func _handle_user_offer_confirm() -> void:
	pass


func _handle_cancel_offer_item(p:CancelOfferItem) -> void:
	pass


func _handle_commerce_chat(p:CommerceChat) -> void:
	pass


func _handle_show_blacksmith_form() -> void:
	pass


func _handle_blacksmith_weapons(p:BlacksmithWeapons) -> void:
	pass


func _handle_blacksmith_armors(p:BlacksmithArmors) -> void:
	pass


func _handle_show_carpenter_form() -> void:
	pass


func _handle_carpenter_objects(p:CarpenterObjects) -> void:
	pass
	
	
func _handle_update_mana(p:UpdateMana) -> void:
	_gameInput.mana_stat_bar.value = p.min_mana
	_gameContext.player_stats.mana = p.min_mana
			
			
func _HandelUpdateExp(p:UpdateExp) -> void:
	_gameInput.experience_stat_bar.value = p.experience
			
			
func _HandleShowMessageBox(p:ShowMessageBox) -> void:
	Utils.ShowAlertDialog("Server", p.message, get_parent())


func _HandlePong() -> void:
	var ping_ms = Time.get_ticks_msec() - _gameContext.pingTime
	print("Ping: %dms" % ping_ms)
	
	# Determinar el color del ping según la latencia
	var ping_color: Color
	if ping_ms < 20:
		ping_color = Color.GREEN  # Verde para ping excelente (< 20ms)
	elif ping_ms < 90:
		ping_color = Color.YELLOW # Amarillo para ping medio (20-89ms)
	else:
		ping_color = Color.RED    # Rojo para ping alto (>= 90ms)
	
	# Mostrar ping en la consola del juego con color dinámico
	_gameInput.ShowConsoleMessage("Ping: %d ms" % ping_ms, FontData.new(ping_color))
	
	_gameContext.pingTime = 0


func _handle_navigate_toggle() -> void:
	_gameContext.userNavegando = !_gameContext.userNavegando


func _handle_pause_toggle() -> void:
	_gameContext.pause = !_gameContext.pause


func _handle_stop_working() -> void:
	_gameInput.ShowConsoleMessage("¡Has terminado de trabajar!", \
		GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
	#TODO Completar
	#If frmMain.macrotrabajo.Enabled Then Call frmMain.DesactivarMacroTrabajo


func _HandleUpdateDexterity(p:UpdateDexterity) -> void:
	_gameInput.update_agility_label(p.dexterity)

	
func _HandleUpdateStrenght(p:UpdateStrenght) -> void:
	_gameInput.update_strength_label(p.strenght)


func _HandleUpdateGold(p:UpdateGold) -> void:
	_gameInput.update_gold_label(p.gold)


func _HandleUpdateBankGold(p:UpdateBankGold) -> void:
	_gameInput.SetBankGold(p.gold)


func _handle_meditate_toggle() -> void:
	_gameContext.userMeditar = !_gameContext.userMeditar


func _handle_rest_ok() -> void:
	_gameContext.userDescansar = !_gameContext.userDescansar

func _handle_blind() -> void:
	_gameContext.userCiego = true

	
func _handle_blind_no_more() -> void:
	_gameContext.userCiego = false


func _handle_dumb() -> void:
	_gameContext.userEstupido = true


func _handle_dumb_no_more() -> void:
	_gameContext.userEstupido = false 


func _handle_paralize_ok() -> void:
	_gameContext.userParalizado = !_gameContext.userParalizado
	
func _handle_send_night(_p:SendNight) -> void:
	pass

func _handle_error_message(p:ErrorMsg) -> void:
	Utils.ShowAlertDialog("Server", p.message, get_tree().root)
	ClientInterface.DisconnectFromHost()


func _HandleChangeBankSlot(p:ChangeBankSlot) -> void:
	var item = Item.new()
	item.index = p.index
	item.name = p.name
	item.type = p.type
	item.maxHit = p.maxHit
	item.minHit = p.minHit
	item.maxDef = p.maxDef
	item.minDef = p.minDef
	item.salePrice = p.salePrice
	
	if p.grhId > 0:
		item.icon = GameAssets.GetTexture(GameAssets.GrhDataList[p.grhId].fileId)
	
	var itemStack = ItemStack.new(p.amount, false, item)
	_gameContext.bankInventory.SetSlot(p.slot -1, itemStack)


func _HandleCommerceInit() -> void:
	_gameInput.OpenMerchant()
	
func _HandleCommerceEnd() -> void:
	_gameInput.CloseMerchant()
	
func _HandleBankInit(p:BankInit) -> void:
	_gameInput.OpenBank()
	_gameInput.SetBankGold(p.gold)

func _HandleBankEnd() -> void:
	_gameInput.CloseBank()

func _HandleChangeNPCInventorySlot(p:ChangeNPCInventorySlot) -> void:
	var item = Item.new()
	item.index = p.index
	item.name = p.name
	item.type = p.type
	item.maxHit = p.maxHit
	item.minHit = p.minHit
	item.maxDef = p.maxDef
	item.minDef = p.minDef
	item.salePrice = p.salePrice
	
	if p.grhId > 0:
		item.icon = GameAssets.GetTexture(GameAssets.GrhDataList[p.grhId].fileId)
	
	var itemStack = ItemStack.new(p.amount, false, item)
	_gameContext.merchantInventory.SetSlot(p.slot -1, itemStack)
		
		
func _HandleChatOverHead(p:ChatOverHead) -> void:
	var character = _gameWorld.GetCharacter(p.charIndex)
	if character:
		character.Say(p.chat, p.color)
			
				
func _HandleUpdateTagAndStatus(p:UpdateTagAndStatus) -> void:
	var character = _gameWorld.GetCharacter(p.charIndex)
	if character:
		character.SetCharacterName(p.userTag)
		character.SetCharacterNameColor(Utils.GetNickColor(p.nickColor, character.priv))


func _HandlePosUpdate(p:PosUpdate) -> void:
	var character = _gameWorld.GetCharacter(_mainCharacterInstanceId)
	if character:
		character.StopMoving()
		character.gridPosition = Vector2i(p.x, p.y)
		character.position = Vector2((p.x - 1) * 32, (p.y - 1) * 32) + Vector2(16, 32);
		_gameInput.minimap.update_player_position(p.x, p.y)


func _HandleForceCharMove(p:ForceCharMove) -> void:
	var character = _gameWorld.GetCharacter(_mainCharacterInstanceId)
	if character:
		character.StopMoving()
		_gameWorld.MoveCharacter(_mainCharacterInstanceId, p.heading)


func _HandleLogged(_p:Logged) -> void:
	pass


func _HandleCharacterChange(p:CharacterChange) -> void:
	var character = _gameWorld.GetCharacter(p.charIndex)
	if character == null: return
	
	character.renderer.body = p.body
	character.renderer.head = p.head
	character.renderer.helmet = p.helmet
	character.renderer.weapon = p.weapon
	character.renderer.shield = p.shield
	character.renderer.heading = p.heading
	
	
func _HandleUpdateHP(p:UpdateHP) -> void:
	_gameInput.health_stat_bar.value = p.hp
	_gameContext.player_stats.hp = p.hp


func _HandleCharacterRemove(p:CharacterRemove) -> void:
	_gameWorld.DeleteCharacter(p.charIndex)


func _HandleRemoveCharDialog(p:RemoveCharDialog) -> void:
	var character = _gameWorld.GetCharacter(p.charIndex)
	if character:
		character.Say("", Color.WHITE)


func _HandleConsoleMessage(p:ConsoleMessage) -> void:
	_gameInput.ShowConsoleMessage(p.message, GameAssets.FontDataList[p.fontIndex])


func _HandleUpdateSta(p:UpdateSta) -> void:
	_gameInput.stamina_stat_bar.value = p.stamina
	_gameContext.player_stats.sta = p.stamina

func _HandleRemoveDialogs() -> void:
	pass

func _HandleLevelUp(p:LevelUp) -> void:
	pass

func _HandleSendSkills(p:SendSkills) -> void:
	_gameInput._show_skills_window(p.skills)
	# Actualizar también la ventana de estadísticas si está abierta
	_gameInput.update_stats_skills(p.skills)

func _HandleAtributes(p:Atributes) -> void:
	# p.attributes: [Fuerza, Agilidad, Inteligencia, Carisma, Constitución]
	_gameInput.update_stats_attributes(p.attributes)

func _HandleFame(p:Fame) -> void:
	var fame = {
		"AsesinoRep": p.AsesinoRep,
		"BandidoRep": p.BandidoRep,
		"BurguesRep": p.BurguesRep,
		"LadronesRep": p.LadronesRep,
		"NobleRep": p.NobleRep,
		"PlebeRep": p.PlebeRep,
		"Promedio": p.Promedio,
	}
	_gameInput.update_stats_fame(fame)

func _HandleMiniStats(p:MiniStats) -> void:
	var mini_stats = {
		"CiudadanosMatados": p.CiudadanosMatados,
		"CriminalesMatados": p.CriminalesMatados,
		"UsuariosMatados": p.UsuariosMatados,
		"NpcsMatados": p.NpcsMatados,
		"Clase": p.Clase,
		"PenaCarcel": p.PenaCarcel,
	}
	_gameInput.update_stats_ministats(mini_stats)

				
func _HandleGuildChat(p:GuildChat) -> void:
	pass


func _HandleUpdateStrengthAndDexterity(p:UpdateStrengthAndDexterity) -> void:
	_gameInput.update_agility_label(p.dexterity)
	_gameInput.update_strength_label(p.strength)


func _HandleUpdateHungerAndThirst(p:UpdateHungerAndThirst) -> void: 
	_gameInput.hunger_stat_bar.max_value = p.maxHam
	_gameInput.hunger_stat_bar.value = p.minHam
	
	_gameInput.thirst_stat_bar.max_value = p.maxAgua
	_gameInput.thirst_stat_bar.value = p.minAgua
	
	
func _HandleUpdateUserStats(p:UpdateUserStats) -> void: 
	# Actualizar la interfaz
	_gameInput.update_gold_label(p.gold)
	_gameInput.update_level_label(p.elv)
	
	_gameInput.experience_stat_bar.max_value = p.elu
	_gameInput.experience_stat_bar.value = p.experience
	
	_gameInput.health_stat_bar.max_value = p.maxHp
	_gameInput.health_stat_bar.value = p.minHp
	
	# Actualizar el contexto del juego
	_gameContext.player_level = p.elv
	_gameContext.player_gold = p.gold
	_gameContext.player_experience = p.experience
	_gameContext.player_experience_to_next_level = p.elu
	
	_gameContext.player_stats.max_hp = p.maxHp
	_gameContext.player_stats.hp = p.minHp
	
	# DEBUG: Mostrar estado del personaje
	print("🜂 DEBUG - Estado del personaje:")
	print("   HP: ", p.minHp, "/", p.maxHp)
	print("   ¿Está vivo?: ", _gameContext.player_stats.is_alive())
	print("   Nivel: ", p.elv)
	print("   Oro: ", p.gold)
	
	_gameInput.mana_stat_bar.max_value = p.maxMana
	_gameInput.mana_stat_bar.value = p.minMana
	
	_gameContext.player_stats.max_mana = p.maxMana
	_gameContext.player_stats.mana = p.minMana
	
	_gameInput.stamina_stat_bar.max_value = p.maxSta
	_gameInput.stamina_stat_bar.value = p.minSta
	
	_gameContext.player_stats.max_sta = p.maxSta
	_gameContext.player_stats.sta = p.minSta


func _HandleUserCharIndexInServer(p:UserCharIndexInServer) -> void:
	_mainCharacterInstanceId = p.charIndex
	var character = _gameWorld.GetCharacter(p.charIndex)
	
	if character:
		character.SetAsPlayer(true)  # Marcar este personaje como el del jugador
		_gameInput.minimap.update_player_position(
			character.gridPosition.x,\
			 character.gridPosition.y)


func _HandleCreateFx(p:CreateFx) -> void:
	var character = _gameWorld.GetCharacter(p.charIndex)
	if character:
		character.effect.play_effect(p.fx, p.fxLoops)


func _HandleSetInvisible(p:SetInvisible) -> void:
	var character = _gameWorld.GetCharacter(p.charIndex)
	if character:
		character.SetCharacterInvisible(!p.invisible)
				
func _HandleCharacterCreate(p:CharacterCreate) -> void:
	var privileges = p.privileges
	if privileges != 0:
		if (privileges & Enums.PlayerType.ChaosCouncil) != 0 && (privileges & Enums.PlayerType.User) == 0:
			privileges  = privileges ^ Enums.PlayerType.ChaosCouncil
		
		if (privileges & Enums.PlayerType.RoyalCouncil) != 0 && (privileges & Enums.PlayerType.User) == 0:
			privileges  = privileges ^ Enums.PlayerType.RoyalCouncil
		
		if (privileges & Enums.PlayerType.RoleMaster) != 0:
			privileges = Enums.PlayerType.RoleMaster
		
		privileges = log(privileges) / log(2)
		
	p.privileges = privileges
	_gameWorld.CreateCharacter(p)

func _HandleCharacterMove(p:CharacterMove) -> void:
	var character = _gameWorld.GetCharacter(p.charIndex)
	if character == null:
		return
		
	var addX = p.x - character.gridPosition.x
	var addY = p.y - character.gridPosition.y
	
	var heading = Enums.Heading.South
	if Utils.Sgn(addX) == 1:
		heading = Enums.Heading.East;
	elif Utils.Sgn(addX) == -1:
		heading = Enums.Heading.West;
	elif Utils.Sgn(addY) == 1:
		heading = Enums.Heading.South;
	elif Utils.Sgn(addY) == -1:
		heading = Enums.Heading.North;
		
	_gameWorld.MoveCharacter(p.charIndex, heading)

func _HandleBlockPosition(p:BlockPosition) -> void:
	if p.blocked:
		_gameWorld.GetMapContainer().BlockTile(p.x -1, p.y - 1)
	else:
		_gameWorld.GetMapContainer().UnblockTile(p.x -1, p.y - 1)


func _HandleObjectCreate(p:ObjectCreate) -> void:
	_gameWorld.AddObject(p.grhId, p.x, p.y)


func _HandleObjectDelete(p:ObjectDelete) -> void:
	_gameWorld.DeleteObject(p.x, p.y)


func _HandleAreaChanged(_p:AreaChanged) -> void:
	pass


func _HandlePlayMidi(p:PlayMidi) -> void:
	pass
	
	
func _handle_show_signal(p:ShowSignal) -> void:
	pass
	
	
func _HandlePlayWave(p:PlayWave) -> void:
	AudioManager.PlayAudio(p.wave, true)  # true = solicitado por servidor


func _HandleChangeMap(p:ChangeMap) -> void:
	_gameWorld.SwitchMap(p.mapId)
	_gameContext.player_map = p.mapId
	_gameInput.minimap.load_thumbnail(p.mapId)
		
		
func _HandleChangeSpellSlot(p:ChangeSpellSlot) -> void:
	_gameInput.spell_list_panel.set_slot_text(p.slot - 1, p.name) 


func _HandleChangeInventorySlot(p:ChangeInventorySlot) -> void:
	var item = Item.new()
	item.index = p.index
	item.name = p.name
	item.type = p.type
	item.maxHit = p.maxHit
	item.minHit = p.minHit
	item.maxDef = p.maxDef
	item.minDef = p.minDef
	item.salePrice = p.salePrice
	
	if p.grhId > 0:
		item.icon = GameAssets.GetTexture(GameAssets.GrhDataList[p.grhId].fileId)
	
	var itemStack = ItemStack.new(p.amount, p.equipped, item)
	_gameContext.playerInventory.SetSlot(p.slot -1, itemStack)
	_gameInput.update_equipment_label(p.slot - 1, itemStack)

func _HandleMultiMessage(p:MultiMessage) -> void:
	match p.index:
		Enums.Messages.SafeModeOn:
			_gameInput.ShowConsoleMessage(">>SEGURO ACTIVADO<<", FontData.new(Color.GREEN, true))
		Enums.Messages.SafeModeOff:
			_gameInput.ShowConsoleMessage(">>SEGURO DESACTIVADO<<", FontData.new(Color.RED, true))
		Enums.Messages.ResuscitationSafeOn:
			_gameInput.ShowConsoleMessage("SEGURO DE RESURRECCION ACTIVADO", FontData.new(Color.GREEN, true))
		Enums.Messages.ResuscitationSafeOff:
			_gameInput.ShowConsoleMessage("SEGURO DE RESURRECCION DESACTIVADO", FontData.new(Color.RED, true))
		#Enums.Messages.DontSeeAnything:
		#	_gameInput.ShowConsoleMessage("No ves nada interesante.", FontData.new(Color.from_rgba8(65, 190, 156)))
		Enums.Messages.NPCSwing:
			_gameInput.ShowConsoleMessage("¡¡¡La criatura falló el golpe!!!", FontData.new(Color.RED, true))
		Enums.Messages.NPCKillUser:
			_gameInput.ShowConsoleMessage("¡¡¡La criatura te ha matado!!!", FontData.new(Color.RED, true))
		Enums.Messages.BlockedWithShieldUser:
			_gameInput.ShowConsoleMessage("¡¡¡Has rechazado el ataque con el escudo!!!", FontData.new(Color.RED, true))
		Enums.Messages.BlockedWithShieldother:
			_gameInput.ShowConsoleMessage("¡¡¡El usuario rechazó el ataque con su escudo!!!", FontData.new(Color.RED, true))
		Enums.Messages.UserSwing:
			_gameInput.ShowConsoleMessage("¡¡¡Has fallado el golpe!!!", FontData.new(Color.RED, true))
		Enums.Messages.NobilityLost:
			_gameInput.ShowConsoleMessage("¡Has perdido nobleza y ganado criminalidad! Sigue así y las tropas te perseguirán.", FontData.new(Color.RED))
		Enums.Messages.CantUseWhileMeditating:
			_gameInput.ShowConsoleMessage("¡Estás meditando! Debes dejar de meditar para usar objetos.", FontData.new(Color.RED))
		Enums.Messages.NPCHitUser:
			match p.arg1:
				Consts.bCabeza:
					_gameInput.ShowConsoleMessage("¡¡La criatura te ha pegado en la cabeza por " + str(p.arg2) + "!!", FontData.new(Color.RED, true))
				Consts.bBrazoIzquierdo:
					_gameInput.ShowConsoleMessage("¡¡La criatura te ha pegado el brazo izquierdo por " + str(p.arg2) + "!!", FontData.new(Color.RED, true))
				Consts.bBrazoDerecho:
					_gameInput.ShowConsoleMessage("¡¡La criatura te ha pegado el brazo derecho por " + str(p.arg2) + "!!", FontData.new(Color.RED, true))
				Consts.bPiernaIzquierda:
					_gameInput.ShowConsoleMessage("¡¡La criatura te ha pegado la pierna izquierda por " + str(p.arg2) + "!!", FontData.new(Color.RED, true))
				Consts.bPiernaDerecha:
					_gameInput.ShowConsoleMessage("¡¡La criatura te ha pegado la pierna derecha por " + str(p.arg2) + "!!", FontData.new(Color.RED, true))
				Consts.bTorso:
					_gameInput.ShowConsoleMessage("¡¡La criatura te ha pegado en el torso por " + str(p.arg2) + "!!", FontData.new(Color.RED, true))
		Enums.Messages.UserHitNPC:
			_gameInput.ShowConsoleMessage("¡¡Le has pegado a la criatura por " + str(p.arg1) + "!!", FontData.new(Color.RED, true))
		Enums.Messages.UserAttackedSwing:
			_gameInput.ShowConsoleMessage("¡¡ " + _gameWorld.GetCharacter(p.arg1).GetCharacterName() + " te atacó y falló!!", FontData.new(Color.RED, true))
		Enums.Messages.UserHittedByUser:
			var charName = _gameWorld.GetCharacter(p.arg1).GetCharacterName() 
			_gameInput.ShowConsoleMessage(Consts.MessageUserHittedByUser[p.arg2].format([charName, p.arg3]), FontData.new(Color.RED)) 
		Enums.Messages.UserHittedUser:
			var charName = _gameWorld.GetCharacter(p.arg1).GetCharacterName()
			_gameInput.ShowConsoleMessage(Consts.MessageUserHittedUser[p.arg2].format([charName, p.arg3]), FontData.new(Color.RED)) 
		Enums.Messages.WorkRequestTarget:
			_gameContext.usingSkill = p.arg1
			_gameInput.ShowConsoleMessage(Consts.MessageWorkRequestTarget[p.arg1], FontData.new(Color.from_rgba8(100, 100, 120)))
			# Asegurarse de que el mouse sea visible
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			
			# Usar cursor personalizado o del sistema según la configuración
			if Global.useCustomCursor and _crosshair_cursor:
				# Escalar el cursor si aún no lo hemos hecho
				if _scaled_crosshair_cursor == null:
					_scaled_crosshair_cursor = _scale_cursor(_crosshair_cursor, 0.1) # Factor de escala 0.5 (50% del tamaño original)
				
				# Usar el cursor escalado
				var cursor_to_use = _scaled_crosshair_cursor if _scaled_crosshair_cursor else _crosshair_cursor
				
				# Usar el centro de la imagen como punto de acción (hotspot)
				var image_size = cursor_to_use.get_size()
				var hotspot = Vector2(image_size.x / 2, image_size.y / 2)
				
				# Usar CURSOR_ARROW para evitar problemas con CURSOR_CROSS
				Input.set_custom_mouse_cursor(cursor_to_use, Input.CURSOR_ARROW, hotspot)
				print("Cursor personalizado activado. Tamaño: %s, Hotspot: %s" % [image_size, hotspot])
			else:
				# Usar cursor de puntería del sistema
				Input.set_default_cursor_shape(Input.CURSOR_CROSS)
		Enums.Messages.HaveKilledUser:
			var charName = _gameWorld.GetCharacter(p.arg1).GetCharacterName()
			_gameInput.ShowConsoleMessage("Has matado a {0}!".format([charName]), FontData.new(Color.RED, true)) 
			_gameInput.ShowConsoleMessage("Has ganado {0} puntos de experiencia.".format([p.arg2]), FontData.new(Color.RED, true)) 
		Enums.Messages.UserKill:
			var charName = _gameWorld.GetCharacter(p.arg1).GetCharacterName()
			_gameInput.ShowConsoleMessage("{0} te ha matado!".format([charName]), FontData.new(Color.RED, true)) 
		Enums.Messages.Home:
			var distance = p.arg1
			var time = p.arg2
			var home = p.string_arg1
			var message = ""
			
			if time >= 60:
				if time % 60 == 0:
					message = "{0} minutos.".format([time / 60.0])
				else:
					message = "{0} minutos y {1} segundos.".format([int(time / 60.0), int(time % 60)]) 
			else:
				message = "{0} segundos.".format([time])
			_gameInput.ShowConsoleMessage("Te encuentras a {0} mapas de la {1}, este viaje durará {2}".format([distance, home, message]), FontData.new(Color.RED, true)) 
			_gameContext.traveling = true
		Enums.Messages.FinishHome:
			_gameInput.ShowConsoleMessage("Has llegado a tu hogar. El viaje ha finalizado.", FontData.new(Color.WHITE)) 
			_gameContext.traveling = false
		Enums.Messages.CancelHome:
			_gameInput.ShowConsoleMessage("Tu viaje ha sido cancelado.", FontData.new(Color.RED)) 
			_gameContext.traveling = false
	
func _FlushData() -> void:
	if !GameProtocol.IsEmpty(): 
		ClientInterface.Send(GameProtocol.Flush())

# Maneja la visualización de la ventana de alineación de gremio
func _HandleShowGuildAlign(show_guild_align) -> void:
	show_guild_align.handle()

# Maneja la visualización del formulario de fundación de gremio
func _HandleShowGuildFundationForm(show_guild_fundation_form) -> void:
	show_guild_fundation_form.handle()

# Maneja la lista simple de clanes (jugador sin clan)
func _handle_guild_list(p: GuildList) -> void:
	_gameInput.show_guild_list(p.guilds)

# Maneja la información de miembro del clan (jugador con clan pero no líder)
func _handle_guild_member_info(p: GuildMemberInfo) -> void:
	_gameInput.show_guild_member_info(p.guild_names, p.guild_members)

# Maneja la información del líder del clan recibida del servidor
func _handle_guild_leader_info(p: GuildLeaderInfo) -> void:
	print("[DEBUG] _handle_guild_leader_info llamado")
	print("[DEBUG] guild_names: ", p.guild_names)
	print("[DEBUG] guild_members: ", p.guild_members)
	print("[DEBUG] guild_news: ", p.guild_news)
	print("[DEBUG] guild_requests: ", p.guild_requests)
	print("[DEBUG] Llamando a update_guild_leader_data...")
	_gameInput.update_guild_leader_data(p.guild_names, p.guild_members, p.guild_news, p.guild_requests)
	print("[DEBUG] update_guild_leader_data completado")

# Maneja los detalles del clan recibidos del servidor
func _handle_guild_details(p: GuildDetails) -> void:
	var data = {
		"name": p.guild_name,
		"founder": p.founder,
		"creation_date": p.creation_date,
		"leader": p.leader,
		"website": p.website,
		"members_count": p.members_count,
		"elections_open": p.elections_open,
		"alignment": p.alignment,
		"enemies_count": p.enemies_count,
		"allies_count": p.allies_count,
		"anti_faction": p.anti_faction,
		"codex": p.codex,
		"description": p.description,
		"is_leader": p.is_leader
	}
	_gameInput.show_guild_details(data)

# Maneja las noticias del clan recibidas del servidor
func _handle_guild_news(p: GuildNews) -> void:
	_gameInput.show_guild_news(p.news, p.enemy_guilds, p.allied_guilds)

# Maneja los detalles de una propuesta (paz o alianza)
func _handle_offer_details(p: OfferDetails) -> void:
	_gameInput.show_offer_details(p.details)

# Maneja la lista de propuestas de alianza
func _handle_alliance_proposals_list(p: AllianceProposalsList) -> void:
	_gameInput.show_alliance_proposals(p.guilds)

# Maneja la lista de propuestas de paz
func _handle_peace_proposals_list(p: PeaceProposalsList) -> void:
	_gameInput.show_peace_proposals(p.guilds)

# Maneja la lista de criaturas para entrenamiento
func _handle_trainer_creature_list(p: TrainerCreatureList) -> void:
	print("[TrainerCreatureList] Criaturas recibidas: ", p.creatures)
	# Mostrar ventana de selección de criaturas
	_gameInput.show_spawn_list(p.creatures)

#endregion


func _OnPingTimerTimeout() -> void:
	if _gameContext.pingTime != 0: return
	GameProtocol.WritePing()
	_FlushData()
	_gameContext.pingTime = Time.get_ticks_msec()
