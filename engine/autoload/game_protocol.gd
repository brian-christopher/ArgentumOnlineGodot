extends Node
class_name GameProtocol

static var _writer:StreamPeerBuffer = StreamPeerBuffer.new()

# Función para registrar comandos salientes al servidor
static func _log_outgoing_packet(packet_name: String, params: String = "") -> void:
	if Global.log_outgoing_packets:
		var log_message = "[OUTGOING] " + packet_name
		if params != "":
			log_message += " | " + params
		print(log_message)

static func Flush() -> PackedByteArray:
	var data = _writer.data_array
	_writer.clear() 
	return data
	
static func IsEmpty() -> bool:
	return _writer.get_size() == 0

static func Clear() -> void:
	_writer.clear()

static func WriteLoginExistingCharacter(username:String, password:String) -> void:
	_log_outgoing_packet("LoginExistingCharacter", "username: " + username + ", password: " + password)
	_writer.put_u8(Enums.ClientPacketID.LoginExistingChar)
	Utils.PutUnicodeString(_writer, username)
	Utils.PutUnicodeString(_writer, password)
	_writer.put_u8(0)
	_writer.put_u8(13)
	_writer.put_u8(0)
	
static func WriteLoginNewChar(username:String, password:String, email:String, job:int, race:int, gender:int, home:int, head:int) -> void:
	_log_outgoing_packet("LoginNewChar", "username: " + username + ", password: " + password + ", email: " + email + ", job: " + str(job) + ", race: " + str(race) + ", gender: " + str(gender) + ", home: " + str(home) + ", head: " + str(head))
	_writer.put_u8(Enums.ClientPacketID.LoginNewChar)
	Utils.PutUnicodeString(_writer, username)
	Utils.PutUnicodeString(_writer, password)
	_writer.put_u8(0)
	_writer.put_u8(13)
	_writer.put_u8(0)
	
	_writer.put_u8(race)
	_writer.put_u8(gender)
	_writer.put_u8(job)
	_writer.put_16(head)
	Utils.PutUnicodeString(_writer, email)
	_writer.put_u8(home)
	
static func WriteThrowDice() -> void:
	_log_outgoing_packet("ThrowDices")
	_writer.put_u8(Enums.ClientPacketID.ThrowDices)
	
static func WriteWalk(heading:int) -> void:
	_log_outgoing_packet("Walk", "heading: " + str(heading))
	_writer.put_u8(Enums.ClientPacketID.Walk) 
	_writer.put_u8(heading)
	
static func WriteChangeHeading(heading:int) -> void:
	_log_outgoing_packet("ChangeHeading", "heading: " + str(heading))
	_writer.put_u8(Enums.ClientPacketID.ChangeHeading) 
	_writer.put_u8(heading) 
	
static func WriteEquipItem(slot:int) -> void:
	_log_outgoing_packet("EquipItem", "slot: " + str(slot))
	_writer.put_u8(Enums.ClientPacketID.EquipItem) 
	_writer.put_u8(slot) 
	
static func WriteUseItem(slot:int) -> void:
	_log_outgoing_packet("UseItem", "slot: " + str(slot))
	_writer.put_u8(Enums.ClientPacketID.UseItem) 
	_writer.put_u8(slot) 
	
static func WriteQuit() -> void:
	_log_outgoing_packet("Quit")
	_writer.put_u8(Enums.ClientPacketID.Quit)
	
static func WriteSafeToggle() -> void:
	_log_outgoing_packet("SafeToggle")
	_writer.put_u8(Enums.ClientPacketID.SafeToggle)
	
static func WriteResuscitationToggle() -> void:
	_log_outgoing_packet("ResuscitationSafeToggle")
	_writer.put_u8(Enums.ClientPacketID.ResuscitationSafeToggle)
	
static func WriteDrop(slot:int, quantity:int) -> void:
	_log_outgoing_packet("Drop", "slot: " + str(slot) + ", quantity: " + str(quantity))
	_writer.put_u8(Enums.ClientPacketID.Drop) 
	_writer.put_u8(slot) 
	_writer.put_16(quantity) 
	
static func WriteDoubleClick(x:int, y:int) -> void:
	_log_outgoing_packet("DoubleClick", "x: " + str(x) + ", y: " + str(y))
	_writer.put_u8(Enums.ClientPacketID.DoubleClick) 
	_writer.put_u8(x)
	_writer.put_u8(y) 

static func WriteLeftClick(x:int, y:int) -> void:
	_log_outgoing_packet("LeftClick", "x: " + str(x) + ", y: " + str(y))
	_writer.put_u8(Enums.ClientPacketID.LeftClick) 
	_writer.put_u8(x)
	_writer.put_u8(y) 
	
static func WriteWorkLeftClick(x:int, y:int, skill:int) -> void:
	_log_outgoing_packet("WorkLeftClick", "x: " + str(x) + ", y: " + str(y) + ", skill: " + str(skill))
	_writer.put_u8(Enums.ClientPacketID.WorkLeftClick) 
	_writer.put_u8(x)
	_writer.put_u8(y) 
	_writer.put_u8(skill) 
	
static func WriteCommerceEnd() -> void:
	_log_outgoing_packet("CommerceEnd")
	_writer.put_u8(Enums.ClientPacketID.CommerceEnd) 
	
static func WriteCommerceSell(slot:int, quantity:int) -> void:
	_log_outgoing_packet("CommerceSell", "slot: " + str(slot) + ", quantity: " + str(quantity))
	_writer.put_u8(Enums.ClientPacketID.CommerceSell) 
	_writer.put_u8(slot)
	_writer.put_16(quantity) 

static func WriteCommerceBuy(slot:int, quantity:int) -> void:
	_log_outgoing_packet("CommerceBuy", "slot: " + str(slot) + ", quantity: " + str(quantity))
	_writer.put_u8(Enums.ClientPacketID.CommerceBuy) 
	_writer.put_u8(slot)
	_writer.put_16(quantity) 

static func WriteCommerceStart() -> void:
	_log_outgoing_packet("CommerceStart")
	_writer.put_u8(Enums.ClientPacketID.CommerceStart)

static func WriteBankStart() -> void:
	_log_outgoing_packet("BankStart")
	_writer.put_u8(Enums.ClientPacketID.BankStart)
	
static func WriteBankEnd() -> void:
	_log_outgoing_packet("BankEnd")
	_writer.put_u8(Enums.ClientPacketID.BankEnd)  
	
static func WriteBankExtractItem(slot:int, quantity:int) -> void:
	_log_outgoing_packet("BankExtractItem", "slot: " + str(slot) + ", quantity: " + str(quantity))
	_writer.put_u8(Enums.ClientPacketID.BankExtractItem) 
	_writer.put_u8(slot)
	_writer.put_16(quantity) 

static func WriteBankDepositItem(slot:int, quantity:int) -> void:
	_log_outgoing_packet("BankDeposit", "slot: " + str(slot) + ", quantity: " + str(quantity))
	_writer.put_u8(Enums.ClientPacketID.BankDeposit) 
	_writer.put_u8(slot)
	_writer.put_16(quantity) 
	
static func WriteBankDepositGold(quantity:int) -> void:
	_log_outgoing_packet("BankDepositGold", "quantity: " + str(quantity))
	_writer.put_u8(Enums.ClientPacketID.BankDepositGold) 
	_writer.put_32(quantity)
	
static func WriteBankExtractGold(quantity:int) -> void:
	_log_outgoing_packet("BankExtractGold", "quantity: " + str(quantity))
	_writer.put_u8(Enums.ClientPacketID.BankExtractGold) 
	_writer.put_32(quantity)

static func WriteRequestAccountState() -> void:
	_log_outgoing_packet("RequestAccountState")
	_writer.put_u8(Enums.ClientPacketID.RequestAccountState)

static func WriteOnline() -> void:
	_log_outgoing_packet("Online")
	_writer.put_u8(Enums.ClientPacketID.Online)

static func WriteGamble(amount:int) -> void:
	_log_outgoing_packet("Gamble", "amount: " + str(amount))
	_writer.put_u8(Enums.ClientPacketID.Gamble)
	_writer.put_16(amount)

static func WriteResucitate() -> void:
	_log_outgoing_packet("Resucitate")
	_writer.put_u8(Enums.ClientPacketID.Resucitate)

static func WriteGuildLeave() -> void:
	_log_outgoing_packet("GuildLeave")
	_writer.put_u8(Enums.ClientPacketID.GuildLeave)

static func WriteHeal() -> void:
	_log_outgoing_packet("Heal")
	_writer.put_u8(Enums.ClientPacketID.Heal)

static func WriteAttack() -> void:
	_log_outgoing_packet("Attack")
	_writer.put_u8(Enums.ClientPacketID.Attack)

static func WritePickup() -> void:
	_log_outgoing_packet("PickUp")
	_writer.put_u8(Enums.ClientPacketID.PickUp)
	
static func WriteRequestPositionUpdate() -> void:
	_log_outgoing_packet("RequestPositionUpdate")
	_writer.put_u8(Enums.ClientPacketID.RequestPositionUpdate)

static func WriteMeditate() -> void:
	_log_outgoing_packet("Meditate")
	_writer.put_u8(Enums.ClientPacketID.Meditate)
	
static func WriteWork(skill:int) -> void:
	_log_outgoing_packet("Work", "skill: " + str(skill))
	_writer.put_u8(Enums.ClientPacketID.Work) 
	_writer.put_u8(skill) 

static func WriteTalk(text:String) -> void:
	_log_outgoing_packet("Talk", "text: " + text)
	_writer.put_u8(Enums.ClientPacketID.Talk) 
	Utils.PutUnicodeString(_writer, text)

static func WriteYell(text:String) -> void:
	_log_outgoing_packet("Yell", "text: " + text)
	_writer.put_u8(Enums.ClientPacketID.Yell)
	Utils.PutUnicodeString(_writer, text)

static func WriteWhisper(receiver:String, text:String) -> void:
	_log_outgoing_packet("Whisper", "receiver: " + receiver + ", text: " + text)
	_writer.put_u8(Enums.ClientPacketID.Whisper)
	Utils.PutUnicodeString(_writer, receiver)
	Utils.PutUnicodeString(_writer, text)

static func WritePing() -> void:
	_log_outgoing_packet("Ping")
	_writer.put_u8(Enums.ClientPacketID.Ping)

static func WriteSpellInfo(slot:int) -> void:
	_log_outgoing_packet("SpellInfo", "slot: " + str(slot))
	_writer.put_u8(Enums.ClientPacketID.SpellInfo) 
	_writer.put_u8(slot) 

static func WriteCastSpell(slot:int) -> void:
	_log_outgoing_packet("CastSpell", "slot: " + str(slot))
	_writer.put_u8(Enums.ClientPacketID.CastSpell) 
	_writer.put_u8(slot) 
	
static func WriteMoveSpell(upwards:bool, slot:int) -> void:
	_log_outgoing_packet("MoveSpell", "upwards: " + str(upwards) + ", slot: " + str(slot))
	_writer.put_u8(Enums.ClientPacketID.MoveSpell) 
	_writer.put_u8(upwards) 
	_writer.put_u8(slot) 

static func WriteWarpChar(username:String, map_id:int, x:int, y:int) -> void:
	_log_outgoing_packet("WarpChar", "username: " + username + ", map_id: " + str(map_id) + ", x: " + str(x) + ", y: " + str(y))
	_writer.put_u8(Enums.ClientPacketID.GMCommands) 
	_writer.put_u8(Enums.EGMCommands.WARP_CHAR) 
	Utils.PutUnicodeString(_writer, username)
	_writer.put_16(map_id) 
	_writer.put_u8(x) 
	_writer.put_u8(y) 

static func WriteRequestStats() -> void:
	_log_outgoing_packet("RequestStats")
	_writer.put_u8(Enums.ClientPacketID.RequestStats)

static func WriteRequestSkills() -> void:
	_log_outgoing_packet("RequestSkills")
	_writer.put_u8(Enums.ClientPacketID.RequestSkills)


static func WriteRequestAtributes() -> void:
	_log_outgoing_packet("RequestAtributes")
	_writer.put_u8(Enums.ClientPacketID.RequestAtributes)


static func WriteRequestMiniStats() -> void:
	_log_outgoing_packet("RequestMiniStats")
	_writer.put_u8(Enums.ClientPacketID.RequestMiniStats)


static func WriteRequestFame() -> void:
	_log_outgoing_packet("RequestFame")
	_writer.put_u8(Enums.ClientPacketID.RequestFame)


static func WriteModifySkills(skills: Array) -> void:
	_log_outgoing_packet("ModifySkills", "skills: " + str(skills))
	_writer.put_u8(Enums.ClientPacketID.ModifySkills)
	for i in range(skills.size()):
		_writer.put_u8(skills[i])

static func write_invisible() -> void:
	_log_outgoing_packet("Invisible")
	_writer.put_u8(Enums.ClientPacketID.GMCommands)
	_writer.put_u8(Enums.EGMCommands.INVISIBLE)

static func change_description(description:String) -> void:
	_log_outgoing_packet("ChangeDescription", "description: " + description)
	_writer.put_u8(Enums.ClientPacketID.ChangeDescription)
	Utils.PutUnicodeString(_writer, description)

# Envía la alineación seleccionada para el nuevo gremio al servidor
# @param alignment_type: Tipo de alineación del gremio (ver Enums.AlignmentType)
static func WriteGuildFundation(alignment_type: int = -1) -> void:
	_log_outgoing_packet("GuildFundation", "alignment_type: " + str(alignment_type))
	_writer.put_u8(Enums.ClientPacketID.GuildFundation)
	_writer.put_u8(alignment_type)

# ===== COMANDOS DE MASCOTAS =====
static func WritePetStand() -> void:
	_log_outgoing_packet("PetStand")
	_writer.put_u8(Enums.ClientPacketID.PetStand)


static func WritePetFollow() -> void:
	_log_outgoing_packet("PetFollow")
	_writer.put_u8(Enums.ClientPacketID.PetFollow)


static func WriteReleasePet() -> void:
	_log_outgoing_packet("ReleasePet")
	_writer.put_u8(Enums.ClientPacketID.ReleasePet)


# ===== COMANDOS DE ENTRENAMIENTO Y DESCANSO =====
static func WriteTrainList() -> void:
	_log_outgoing_packet("TrainList")
	_writer.put_u8(Enums.ClientPacketID.TrainList)


static func WriteRest() -> void:
	_log_outgoing_packet("Rest")
	_writer.put_u8(Enums.ClientPacketID.Rest)


# ===== COMANDOS DE INFORMACIÓN =====
static func WriteConsultation() -> void:
	_log_outgoing_packet("Consultation")
	_writer.put_u8(Enums.ClientPacketID.Consultation)


static func WriteHelp() -> void:
	_log_outgoing_packet("Help")
	_writer.put_u8(Enums.ClientPacketID.Help)


static func WriteEnlist() -> void:
	_log_outgoing_packet("Enlist")
	_writer.put_u8(Enums.ClientPacketID.Enlist)


static func WriteInformation() -> void:
	_log_outgoing_packet("Information")
	_writer.put_u8(Enums.ClientPacketID.Information)


static func WriteReward() -> void:
	_log_outgoing_packet("Reward")
	_writer.put_u8(Enums.ClientPacketID.Reward)


static func WriteRequestMOTD() -> void:
	_log_outgoing_packet("RequestMOTD")
	_writer.put_u8(Enums.ClientPacketID.RequestMOTD)


static func WriteUpTime() -> void:
	_log_outgoing_packet("UpTime")
	_writer.put_u8(Enums.ClientPacketID.Uptime)


# ===== COMANDOS DE PARTY =====
static func WritePartyLeave() -> void:
	_log_outgoing_packet("PartyLeave")
	_writer.put_u8(Enums.ClientPacketID.PartyLeave)


static func WritePartyCreate() -> void:
	_log_outgoing_packet("PartyCreate")
	_writer.put_u8(Enums.ClientPacketID.PartyCreate)


static func WritePartyJoin(nickname: String) -> void:
	_log_outgoing_packet("PartyJoin")
	_writer.put_u8(Enums.ClientPacketID.PartyJoin)
	_writer.put_string(nickname)


static func WriteShareNpc() -> void:
	_log_outgoing_packet("ShareNpc")
	_writer.put_u8(Enums.ClientPacketID.ShareNpc)


static func WriteStopSharingNpc() -> void:
	_log_outgoing_packet("StopSharingNpc")
	_writer.put_u8(Enums.ClientPacketID.StopSharingNpc)


static func WritePartyKick(nickname:String) -> void:
	_log_outgoing_packet("PartyKick", "nickname: " + nickname)
	_writer.put_u8(Enums.ClientPacketID.PartyKick)
	Utils.PutUnicodeString(_writer, nickname)


static func WritePartySetLeader(nickname:String) -> void:
	_log_outgoing_packet("PartySetLeader", "nickname: " + nickname)
	_writer.put_u8(Enums.ClientPacketID.PartySetLeader)
	Utils.PutUnicodeString(_writer, nickname)


static func WritePartyAcceptMember(nickname:String) -> void:
	_log_outgoing_packet("PartyAcceptMember", "nickname: " + nickname)
	_writer.put_u8(Enums.ClientPacketID.PartyAcceptMember)
	Utils.PutUnicodeString(_writer, nickname)


# ===== COMANDOS DE ENCUESTAS Y MENSAJES =====
static func WriteInquiry() -> void:
	_log_outgoing_packet("Inquiry")
	_writer.put_u8(Enums.ClientPacketID.Inquiry)


static func WriteInquiryVote(vote:int) -> void:
	_log_outgoing_packet("InquiryVote", "vote: " + str(vote))
	_writer.put_u8(Enums.ClientPacketID.InquiryVote)
	_writer.put_u8(vote)


static func WriteGuildMessage(message:String) -> void:
	_log_outgoing_packet("GuildMessage", "message: " + message)
	_writer.put_u8(Enums.ClientPacketID.GuildMessage)
	Utils.PutUnicodeString(_writer, message)


static func WritePartyMessage(message:String) -> void:
	_log_outgoing_packet("PartyMessage", "message: " + message)
	_writer.put_u8(Enums.ClientPacketID.PartyMessage)
	Utils.PutUnicodeString(_writer, message)


static func WriteCentinelReport(code:int) -> void:
	_log_outgoing_packet("CentinelReport", "code: " + str(code))
	_writer.put_u8(Enums.ClientPacketID.CentinelReport)
	_writer.put_16(code)


static func WriteGuildOnline() -> void:
	_log_outgoing_packet("GuildOnline")
	_writer.put_u8(Enums.ClientPacketID.GuildOnline)


static func WritePartyOnline() -> void:
	_log_outgoing_packet("PartyOnline")
	_writer.put_u8(Enums.ClientPacketID.PartyOnline)


static func WriteCouncilMessage(message:String) -> void:
	_log_outgoing_packet("CouncilMessage", "message: " + message)
	_writer.put_u8(Enums.ClientPacketID.CouncilMessage)
	Utils.PutUnicodeString(_writer, message)

static func WriteGuildFundate() -> void:
	_log_outgoing_packet("GuildFundate")
	_writer.put_u8(Enums.ClientPacketID.GuildFundate)

static func WriteRoleMasterRequest(question:String) -> void:
	_log_outgoing_packet("RoleMasterRequest", "question: " + question)
	_writer.put_u8(Enums.ClientPacketID.RoleMasterRequest)
	Utils.PutUnicodeString(_writer, question)


static func WriteGMRequest() -> void:
	_log_outgoing_packet("GMRequest")
	_writer.put_u8(Enums.ClientPacketID.GMRequest)


static func WriteBugReport(description:String) -> void:
	_log_outgoing_packet("BugReport", "description: " + description)
	_writer.put_u8(Enums.ClientPacketID.BugReport)
	Utils.PutUnicodeString(_writer, description)



# ===== COMANDOS DE CLAN =====
static func WriteGuildVote(nickname:String) -> void:
	_log_outgoing_packet("GuildVote", "nickname: " + nickname)
	_writer.put_u8(Enums.ClientPacketID.GuildVote)
	Utils.PutUnicodeString(_writer, nickname)


static func WritePunishments(nickname:String) -> void:
	_log_outgoing_packet("Punishments", "nickname: " + nickname)
	_writer.put_u8(Enums.ClientPacketID.Punishments)
	Utils.PutUnicodeString(_writer, nickname)


# ===== COMANDOS VARIOS =====
static func WriteLeaveFaction() -> void:
	_log_outgoing_packet("LeaveFaction")
	_writer.put_u8(Enums.ClientPacketID.LeaveFaction)


static func WriteDenounce(denounce_text:String) -> void:
	_log_outgoing_packet("Denounce", "denounce_text: " + denounce_text)
	_writer.put_u8(Enums.ClientPacketID.Denounce)
	Utils.PutUnicodeString(_writer, denounce_text)


static func WriteChangePassword(current_password:String, new_password:String) -> void:
	_log_outgoing_packet("ChangePassword", "current_password: [HIDDEN], new_password: [HIDDEN]")
	_writer.put_u8(Enums.ClientPacketID.ChangePassword)
	Utils.PutUnicodeString(_writer, current_password)
	Utils.PutUnicodeString(_writer, new_password)


# ===== COMANDOS GM =====
static func WriteTeleportChar(username:String, map:int, x:int, y:int) -> void:
	_log_outgoing_packet("TeleportChar", "username: " + username + ", map: " + str(map) + ", x: " + str(x) + ", y: " + str(y))
	_writer.put_u8(Enums.ClientPacketID.GMCommands)
	_writer.put_u8(Enums.EGMCommands.WARP_CHAR)
	Utils.PutUnicodeString(_writer, username)
	_writer.put_16(map)
	_writer.put_u8(x)
	_writer.put_u8(y)


static func WriteWarpMeToTarget() -> void:
	_log_outgoing_packet("WarpMeToTarget")
	_writer.put_u8(Enums.ClientPacketID.GMCommands)
	_writer.put_u8(Enums.EGMCommands.WARP_ME_TO_TARGET)
