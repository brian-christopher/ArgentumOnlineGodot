extends Node
class_name ConsoleCommandProcessor

# Importar la ventana de alineación
const ALIGNMENT_WINDOW = preload("res://ui/hub/guild_alignment_window.tscn")

static var command_handler:Dictionary[String, Callable] = {
	"salir": quit,
	"est": request_stats,
	"invisible": invisible,
	"meditar": meditate,
	"desc": change_description,
	"boveda": open_vault,
	"depositar": deposit_gold,
	"retirar": withdraw_gold,
	"balance": request_balance,
	"online": request_online,
	"apostar": gamble,
	"resucitar": resucitate,
	"salirclan": guild_leave,
	"curar": heal,
	"comerciar": start_commerce,
	"quieto": pet_stand,
	"acompañar": pet_follow,
	"liberar": release_pet,
	"entrenar": train_list,
	"descansar": rest,
	"consulta": consultation,
	"ayuda": help,
	"enlistar": enlist,
	"pruebadialogo": test_dialog,
	"informacion": information,
	"recompensa": reward,
	"motd": request_motd,
	"uptime": uptime,
	"salirparty": party_leave,
	"crearparty": party_create,
	"party": party_join,
	"compartirnpc": share_npc,
	"nocompartirnpc": stop_sharing_npc,
	"encuesta": inquiry,
	"cmsg": guild_message,
	"pmsg": party_message,
	"centinela": centinel_report,
	"onlineclan": guild_online,
	"onlineparty": party_online,
	"bmsg": council_message,
	"rol": role_master_request,
	"gm": gm_request,
	"_bug": bug_report,
	"voto": guild_vote,
	"penas": punishments,
	"fundarclan": guild_fundate,
	"contraseña": change_password,
	"retirarfaccion": leave_faction,
	"denunciar": denounce,
	"echarparty": party_kick,
	"partylider": party_set_leader,
	"acceptparty": party_accept_member,
	"telep": teleport_char,
	"teleploc": teleport_me_to_target,
	"hogar": home,
	"ping": ping
}

static func process(newText: String, hub_controller:HubController, game_context:GameContext) -> bool:
	var text = newText.strip_edges()
	
	if text.begins_with("/"):
		if text.length() == 1:
			return false
			
		var command_name = text.substr(1).split(" ")[0].to_lower()
		var args = ChatCommandArgs.new()
		args.parameters = text.substr(1).split(" ")
		args.parameters.remove_at(0)
		args.game_context = game_context
		args.hub_controller = hub_controller
		
		if command_handler.has(command_name): 
			command_handler[command_name].call(args)
			return true
	return false
	
		
static func quit(args:ChatCommandArgs) -> void:
	GameProtocol.WriteQuit()
	
	
static func request_stats(args:ChatCommandArgs) -> void:
	GameProtocol.WriteRequestStats()

	
static func invisible(args:ChatCommandArgs) -> void:
	GameProtocol.write_invisible()


static func meditate(args:ChatCommandArgs) -> void:
	if args.game_context.player_stats.mana == args.game_context.player_stats.max_mana:
		return
		
	if !args.game_context.player_stats.is_alive():
		args.hub_controller.ShowConsoleMessage("¡Estas muerto!", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	GameProtocol.WriteMeditate()
	
static func resucitate(args:ChatCommandArgs) -> void:
	if args.game_context.player_stats.is_alive():
		args.hub_controller.ShowConsoleMessage("¡Ya estás vivo!", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	GameProtocol.WriteResucitate()


static func change_description(args:ChatCommandArgs) -> void:
	if !args.game_context.player_stats.is_alive():
		args.hub_controller.ShowConsoleMessage("¡Estas muerto!", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	var description = " ".join(args.parameters) if args.parameters.size() else ""
	GameProtocol.change_description(description)


static func open_vault(args:ChatCommandArgs) -> void:
	if !args.game_context.player_stats.is_alive():
		args.hub_controller.ShowConsoleMessage("¡Estás muerto!", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	GameProtocol.WriteBankStart()


static func deposit_gold(args:ChatCommandArgs) -> void:
	if !args.game_context.player_stats.is_alive():
		args.hub_controller.ShowConsoleMessage("¡Estás muerto!", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	if args.parameters.size() == 0:
		args.hub_controller.ShowConsoleMessage("Faltan parámetros. Utilice /depositar CANTIDAD.", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	var amount_str = args.parameters[0]
	if !amount_str.is_valid_int():
		args.hub_controller.ShowConsoleMessage("Cantidad incorrecta. Utilice /depositar CANTIDAD.", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	var amount = amount_str.to_int()
	if amount <= 0:
		args.hub_controller.ShowConsoleMessage("Cantidad incorrecta. Utilice /depositar CANTIDAD.", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	GameProtocol.WriteBankDepositGold(amount)


static func withdraw_gold(args:ChatCommandArgs) -> void:
	if !args.game_context.player_stats.is_alive():
		args.hub_controller.ShowConsoleMessage("¡Estás muerto!", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	if args.parameters.size() == 0:
		args.hub_controller.ShowConsoleMessage("Faltan parámetros. Utilice /retirar CANTIDAD.", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	var amount_str = args.parameters[0]
	if !amount_str.is_valid_int():
		args.hub_controller.ShowConsoleMessage("Cantidad incorrecta. Utilice /retirar CANTIDAD.", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	var amount = amount_str.to_int()
	if amount <= 0:
		args.hub_controller.ShowConsoleMessage("Cantidad incorrecta. Utilice /retirar CANTIDAD.", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	GameProtocol.WriteBankExtractGold(amount)


static func request_balance(args:ChatCommandArgs) -> void:
	if !args.game_context.player_stats.is_alive():
		args.hub_controller.ShowConsoleMessage("¡Estás muerto!", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	GameProtocol.WriteRequestAccountState()


static func request_online(args:ChatCommandArgs) -> void:
	GameProtocol.WriteOnline()


static func guild_leave(args:ChatCommandArgs) -> void:
	GameProtocol.WriteGuildLeave()


static func heal(args:ChatCommandArgs) -> void:
	if !args.game_context.player_stats.is_alive():
		GameProtocol.WriteResucitate()
		return
	
	GameProtocol.WriteHeal()


static func start_commerce(args:ChatCommandArgs) -> void:
	if !args.game_context.player_stats.is_alive():
		args.hub_controller.ShowConsoleMessage("¡¡Estás muerto!!", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	if args.game_context.trading:
		args.hub_controller.ShowConsoleMessage("Ya estás comerciando", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	GameProtocol.WriteCommerceStart()


static func gamble(args:ChatCommandArgs) -> void:
	if !args.game_context.player_stats.is_alive():
		args.hub_controller.ShowConsoleMessage("¡¡Estás muerto!!", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	if args.parameters.size() == 0:
		args.hub_controller.ShowConsoleMessage("Faltan parámetros. Utilice /apostar CANTIDAD.", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	var amount_str = args.parameters[0]
	if !amount_str.is_valid_int():
		args.hub_controller.ShowConsoleMessage("Cantidad incorrecta. Utilice /apostar CANTIDAD.", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	var amount = amount_str.to_int()
	if amount <= 0:
		args.hub_controller.ShowConsoleMessage("Cantidad incorrecta. Utilice /apostar CANTIDAD.", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	GameProtocol.WriteGamble(amount)


# ===== COMANDOS DE MASCOTAS =====
static func pet_stand(args:ChatCommandArgs) -> void:
	if !args.game_context.player_stats.is_alive():
		args.hub_controller.ShowConsoleMessage("¡¡Estás muerto!!", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	GameProtocol.WritePetStand()


static func pet_follow(args:ChatCommandArgs) -> void:
	if !args.game_context.player_stats.is_alive():
		args.hub_controller.ShowConsoleMessage("¡¡Estás muerto!!", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	GameProtocol.WritePetFollow()


static func release_pet(args:ChatCommandArgs) -> void:
	if !args.game_context.player_stats.is_alive():
		args.hub_controller.ShowConsoleMessage("¡¡Estás muerto!!", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	GameProtocol.WriteReleasePet()


# ===== COMANDOS DE ENTRENAMIENTO Y DESCANSO =====
static func train_list(args:ChatCommandArgs) -> void:
	if !args.game_context.player_stats.is_alive():
		args.hub_controller.ShowConsoleMessage("¡¡Estás muerto!!", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	# Informar al usuario que necesita seleccionar un NPC entrenador
	args.hub_controller.ShowConsoleMessage("Haz click sobre un entrenador para ver las criaturas disponibles...", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
	
	GameProtocol.WriteTrainList()


static func rest(args:ChatCommandArgs) -> void:
	if !args.game_context.player_stats.is_alive():
		args.hub_controller.ShowConsoleMessage("¡¡Estás muerto!!", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	GameProtocol.WriteRest()


# ===== COMANDOS DE INFORMACIÓN =====
static func consultation(args:ChatCommandArgs) -> void:
	GameProtocol.WriteConsultation()


static func help(args:ChatCommandArgs) -> void:
	GameProtocol.WriteHelp()


static func enlist(args:ChatCommandArgs) -> void:
	GameProtocol.WriteEnlist()


static func information(args:ChatCommandArgs) -> void:
	GameProtocol.WriteInformation()


static func reward(args:ChatCommandArgs) -> void:
	GameProtocol.WriteReward()


static func request_motd(args:ChatCommandArgs) -> void:
	GameProtocol.WriteRequestMOTD()


static func uptime(args:ChatCommandArgs) -> void:
	GameProtocol.WriteUpTime()


# ===== COMANDOS DE PARTY =====
static func party_leave(args:ChatCommandArgs) -> void:
	GameProtocol.WritePartyLeave()


static func party_create(args:ChatCommandArgs) -> void:
	if !args.game_context.player_stats.is_alive():
		args.hub_controller.ShowConsoleMessage("¡¡Estás muerto!!", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	GameProtocol.WritePartyCreate()


static func party_join(args:ChatCommandArgs) -> void:
	if !args.game_context.player_stats.is_alive():
		args.hub_controller.ShowConsoleMessage("¡¡Estás muerto!!", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	GameProtocol.WritePartyJoin()


static func share_npc(args:ChatCommandArgs) -> void:
	if !args.game_context.player_stats.is_alive():
		args.hub_controller.ShowConsoleMessage("¡¡Estás muerto!!", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	GameProtocol.WriteShareNpc()


static func stop_sharing_npc(args:ChatCommandArgs) -> void:
	if !args.game_context.player_stats.is_alive():
		args.hub_controller.ShowConsoleMessage("¡¡Estás muerto!!", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	GameProtocol.WriteStopSharingNpc()


static func party_kick(args:ChatCommandArgs) -> void:
	if args.parameters.size() == 0:
		args.hub_controller.ShowConsoleMessage("Faltan parámetros. Utilice /echarparty NICKNAME.", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	var nickname = args.parameters[0]
	GameProtocol.WritePartyKick(nickname)


static func party_set_leader(args:ChatCommandArgs) -> void:
	if args.parameters.size() == 0:
		args.hub_controller.ShowConsoleMessage("Faltan parámetros. Utilice /partylider NICKNAME.", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	var nickname = args.parameters[0]
	GameProtocol.WritePartySetLeader(nickname)


static func party_accept_member(args:ChatCommandArgs) -> void:
	if args.parameters.size() == 0:
		args.hub_controller.ShowConsoleMessage("Faltan parámetros. Utilice /acceptparty NOMBRE.", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	var username = args.parameters[0]
	GameProtocol.WritePartyAcceptMember(username)


# ===== COMANDOS GM =====
static func teleport_char(args:ChatCommandArgs) -> void:
	# Caso 1: /telep NICKNAME MAPA X Y
	if args.parameters.size() >= 4:
		var username = args.parameters[0]
		var map_str = args.parameters[1]
		var x_str = args.parameters[2]
		var y_str = args.parameters[3]
		
		# Validar que los parámetros numéricos sean válidos
		if not map_str.is_valid_int() or not x_str.is_valid_int() or not y_str.is_valid_int():
			args.hub_controller.ShowConsoleMessage("Valor incorrecto. Utilice /telep NICKNAME MAPA X Y.", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
			return
		
		var map = map_str.to_int()
		var x = x_str.to_int()
		var y = y_str.to_int()
		
		# Enviar el comando al servidor
		GameProtocol.WriteTeleportChar(username, map, x, y)
	
	# Caso 2: /telep MAPA X Y (teleporta al propio usuario)
	elif args.parameters.size() == 3:
		var map_str = args.parameters[0]
		var x_str = args.parameters[1]
		var y_str = args.parameters[2]
		
		# Validar que los parámetros numéricos sean válidos
		if not map_str.is_valid_int() or not x_str.is_valid_int() or not y_str.is_valid_int():
			args.hub_controller.ShowConsoleMessage("Valor incorrecto. Utilice /telep MAPA X Y.", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
			return
		
		var map = map_str.to_int()
		var x = x_str.to_int()
		var y = y_str.to_int()
		
		# Enviar el comando al servidor usando "YO" como nombre de usuario
		GameProtocol.WriteTeleportChar("YO", map, x, y)
	
	# Caso de error: faltan parámetros
	else:
		args.hub_controller.ShowConsoleMessage("Faltan parámetros. Utilice /telep NICKNAME MAPA X Y o /telep MAPA X Y.", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])


static func teleport_me_to_target(args:ChatCommandArgs) -> void:
	# Enviar el comando al servidor
	GameProtocol.WriteWarpMeToTarget()


# ===== COMANDOS DE ENCUESTAS Y MENSAJES =====
static func inquiry(args:ChatCommandArgs) -> void:
	if args.parameters.size() == 0:
		# Version sin argumentos: Inquiry
		GameProtocol.WriteInquiry()
	else:
		# Version con argumentos: InquiryVote
		var vote_str = args.parameters[0]
		if !vote_str.is_valid_int():
			args.hub_controller.ShowConsoleMessage("Para votar una opción, escribe /encuesta NUMERODEOPCION, por ejemplo para votar la opción 1, escribe /encuesta 1.", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
			return
		
		var vote = vote_str.to_int()
		GameProtocol.WriteInquiryVote(vote)


static func guild_message(args:ChatCommandArgs) -> void:
	var message = " ".join(args.parameters) if args.parameters.size() > 0 else ""
	GameProtocol.WriteGuildMessage(message)


static func party_message(args:ChatCommandArgs) -> void:
	var message = " ".join(args.parameters) if args.parameters.size() > 0 else ""
	GameProtocol.WritePartyMessage(message)


static func centinel_report(args:ChatCommandArgs) -> void:
	if args.parameters.size() == 0:
		args.hub_controller.ShowConsoleMessage("Faltan parámetros. Utilice /centinela X, siendo X el código de verificación.", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	var code_str = args.parameters[0]
	if !code_str.is_valid_int():
		args.hub_controller.ShowConsoleMessage("El código de verificación debe ser numérico. Utilice /centinela X, siendo X el código de verificación.", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	var code = code_str.to_int()
	GameProtocol.WriteCentinelReport(code)


static func guild_online(args:ChatCommandArgs) -> void:
	GameProtocol.WriteGuildOnline()


static func party_online(args:ChatCommandArgs) -> void:
	GameProtocol.WritePartyOnline()


static func council_message(args:ChatCommandArgs) -> void:
	if args.parameters.size() == 0:
		args.hub_controller.ShowConsoleMessage("Escriba un mensaje.", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	var message = " ".join(args.parameters)
	GameProtocol.WriteCouncilMessage(message)


static func role_master_request(args:ChatCommandArgs) -> void:
	if args.parameters.size() == 0:
		args.hub_controller.ShowConsoleMessage("Escriba una pregunta.", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	var question = " ".join(args.parameters)
	GameProtocol.WriteRoleMasterRequest(question)


static func gm_request(args:ChatCommandArgs) -> void:
	GameProtocol.WriteGMRequest()


static func bug_report(args:ChatCommandArgs) -> void:
	if args.parameters.size() == 0:
		args.hub_controller.ShowConsoleMessage("Escriba una descripción del bug.", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	var description = " ".join(args.parameters)
	GameProtocol.WriteBugReport(description)


# ===== COMANDOS DE CLAN =====
static func guild_vote(args:ChatCommandArgs) -> void:
	if args.parameters.size() == 0:
		args.hub_controller.ShowConsoleMessage("Faltan parámetros. Utilice /voto NICKNAME.", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	var nickname = args.parameters[0]
	GameProtocol.WriteGuildVote(nickname)


static func punishments(args:ChatCommandArgs) -> void:
	if args.parameters.size() == 0:
		args.hub_controller.ShowConsoleMessage("Faltan parámetros. Utilice /penas NICKNAME.", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	var nickname = args.parameters[0]
	GameProtocol.WritePunishments(nickname)


# ===== COMANDOS VARIOS =====
static func change_password(args:ChatCommandArgs) -> void:
	args.hub_controller.show_password_change_window()


static func leave_faction(args:ChatCommandArgs) -> void:
	if !args.game_context.player_stats.is_alive():
		args.hub_controller.ShowConsoleMessage("¡¡Estás muerto!!", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	GameProtocol.WriteLeaveFaction()


static func denounce(args:ChatCommandArgs) -> void:
	if args.parameters.size() == 0:
		args.hub_controller.ShowConsoleMessage("Formule su denuncia.", GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	var denounce_text = " ".join(args.parameters)
	GameProtocol.WriteDenounce(denounce_text)


static func guild_fundate(args:ChatCommandArgs) -> void:
	# Verificar si el jugador ya está en un clan
	if args.game_context.player_stats.is_in_guild():
		args.hub_controller.ShowConsoleMessage("¡Ya perteneces a un clan! Debes abandonarlo antes de fundar uno nuevo.", 
			GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
		
	# Verificar nivel mínimo (nivel 25)
	if args.game_context.player_level < 25:
		args.hub_controller.ShowConsoleMessage("Debes ser al menos nivel 25 para fundar un clan.", 
			GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	# Verificar si el jugador tiene suficiente oro (50,000 monedas de oro)
	if args.game_context.player_gold < 50000:
		args.hub_controller.ShowConsoleMessage("Necesitas 50,000 monedas de oro para fundar un clan.", 
			GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	# Enviar solicitud al servidor para verificar si el jugador puede fundar un clan
	GameProtocol.WriteGuildFundate()

static func home(args:ChatCommandArgs) -> void:
	# El comando /HOGAR funciona solo cuando estás muerto
	if args.game_context.player_stats.is_alive():
		args.hub_controller.ShowConsoleMessage("Debes estar muerto para utilizar este comando.", 
			GameAssets.FontDataList[Enums.FontTypeNames.FontType_Info])
		return
	
	# Enviar comando al servidor (solo si está muerto)
	GameProtocol.WriteHome()

static func ping(args:ChatCommandArgs) -> void:
	# Prevenir envío de ping si ya hay uno pendiente (como en VB6)
	if args.game_context.pingTime != 0:
		return
	
	# Enviar ping al servidor y registrar tiempo
	GameProtocol.WritePing()
	
	# Flush del buffer inmediatamente (como en VB6)
	if !GameProtocol.IsEmpty():
		ClientInterface.Send(GameProtocol.Flush())
	
	# Registrar el tiempo después del envío
	args.game_context.pingTime = Time.get_ticks_msec()

static func ping_from_button() -> void:
	# Enviar ping desde botón (sin verificar ping pendiente)
	GameProtocol.WritePing()
	
	# Flush del buffer inmediatamente (como en VB6)
	if !GameProtocol.IsEmpty():
		ClientInterface.Send(GameProtocol.Flush())

static func test_dialog(args:ChatCommandArgs) -> void:
	var test_messages = [
		"¡Por los antiguos dragones de Argentum! Este es un mensaje de prueba con texto tipográfico animado.",
		"Velocidad: rápida",
		"Este es un mensaje más largo para probar cómo funciona el autowrap cuando el texto es extenso y necesita hacer saltos de línea automáticamente mientras se escribe letra por letra.",
		"¡Mágia y poder en cada palabra!"
	]
	
	var random_message = test_messages[randi() % test_messages.size()]
	var color = Color.WHITE
	
	# Simular el comando Say del personaje
	if args.game_context and args.game_context.has_method("Say"):
		args.game_context.Say(random_message, color)
	else:
		# Buscar el personaje del jugador en la escena
		var game_screen = args.game_context.get_parent()
		if game_screen and game_screen.has_node("Player"):
			var player = game_screen.get_node("Player") as Character
			if player:
				player.Say(random_message, color)
