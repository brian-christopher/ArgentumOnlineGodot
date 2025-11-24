extends RefCounted
class_name Enums

enum Class{ 
	None,
	Mage = 1,
	Cleric,
	Warrior,
	Assassin,
	Thief,
	Bard,
	Druid,
	Bandit,
	Paladin,
	Hunter,
	Worker,
	Pirat
}

enum Race{ 
	None,
	Human = 1,
	Elf,
	Drow,
	Gnome,
	Dwarf
}

enum Home{
	None = 0,
	Ullathorpe = 1,
	Nix,
	Banderbill,
	Lindos,
	Arghal,
	Arkhein,
	LastCity
};

enum TileState {
	None = 0,
	Blocked = 1 << 0, 
	Roof = 1 << 1,
	Water = 1 << 2,
} 

enum Heading{
	None,
	North,
	East,
	South,
	West,
}

enum Skill{
	None = 0,
	Magia = 1,
	Robar = 2,
	Tacticas = 3,
	Armas = 4,
	Meditar = 5,
	Apunalar = 6,
	Ocultarse = 7,
	Supervivencia = 8,
	Talar = 9,
	Comerciar = 10,
	Defensa = 11,
	Pesca = 12,
	Mineria = 13,
	Carpinteria = 14,
	Herreria = 15,
	Liderazgo = 16,
	Domar = 17,
	Proyectiles = 18,
	Wrestling = 19,
	Navegacion = 20,

	# FIXME: Revisar esto!
	FundirMetal = 88
}

enum eMoveType {
	Inventory = 1,
	Bank
}

enum eOBJType {
	eOBJType_Null = 0,
	eOBJType_otUseOnce = 1,
	eOBJType_otWeapon = 2,
	eOBJType_otArmadura = 3,
	eOBJType_otArboles = 4,
	eOBJType_otGuita = 5,
	eOBJType_otPuertas = 6,
	eOBJType_otContenedores = 7,
	eOBJType_otCarteles = 8,
	eOBJType_otLlaves = 9,
	eOBJType_otForos = 10,
	eOBJType_otPociones = 11,
	eOBJType_otBebidas = 13,
	eOBJType_otLena = 14,
	eOBJType_otFogata = 15,
	eOBJType_otESCUDO = 16,
	eOBJType_otCASCO = 17,
	eOBJType_otAnillo = 18,
	eOBJType_otTeleport = 19,
	eOBJType_otYacimiento = 22,
	eOBJType_otMinerales = 23,
	eOBJType_otPergaminos = 24,
	eOBJType_otInstrumentos = 26,
	eOBJType_otYunque = 27,
	eOBJType_otFragua = 28,
	eOBJType_otBarcos = 31,
	eOBJType_otFlechas = 32,
	eOBJType_otBotellaVacia = 33,
	eOBJType_otBotellaLlena = 34,
	
	#No se usa 
	eOBJType_otManchas = 35,
	eOBJType_otArbolElfico = 36,
	eOBJType_otMochilas = 37,
	eOBJType_otYacimientoPez = 38,
	eOBJType_otCualquiera = 1000
}

enum Messages {
	DontSeeAnything,
	NPCSwing,
	NPCKillUser,
	BlockedWithShieldUser,
	BlockedWithShieldother,
	UserSwing,
	SafeModeOn,
	SafeModeOff,
	ResuscitationSafeOff,
	ResuscitationSafeOn,
	NobilityLost,
	CantUseWhileMeditating,
	NPCHitUser,
	UserHitNPC,
	UserAttackedSwing,
	UserHittedByUser,
	UserHittedUser,
	WorkRequestTarget,
	HaveKilledUser,
	UserKill,
	EarnExp,
	Home,
	CancelHome,
	FinishHome
};
	
enum FontTypeNames {
	FontType_Talk,
	FontType_Fight,
	FontType_Warning,
	FontType_Info,
	FontType_InfoBold,
	FontType_Ejecucion,
	FontType_Party,
	FontType_Veneno,
	FontType_Guild,
	FontType_Server,
	FontType_GuildMsg,
	FontType_Consejo,
	FontType_ConsejoCaos,
	FontType_ConsejoVesA,
	FontType_ConsejoCaosVesA,
	FontType_Centinela,
	FontType_GMMsg,
	FontType_GM,
	FontType_Citizen,
	FontType_Conse,
	FontType_Dios
}

enum PlayerType {
	None = 0,
	User = 1 << 0,         # 1
	Consejero = 1 << 1,    # 2
	SemiDios = 1 << 2,     # 4
	Dios = 1 << 3,         # 8
	Admin = 1 << 4,        # 16
	RoleMaster = 1 << 5,   # 32
	ChaosCouncil = 1 << 6, # 64
	RoyalCouncil = 1 << 7  # 128
}

enum NickColor {
	None = 0,
	IeCriminal = 1 << 0,  # 1
	IeCiudadano = 1 << 1, # 2
	IeAtacable = 1 << 2   # 4
}

# ServerPacketID: Is the protocol from the server to the client
enum ServerPacketID {
	Logged,
	RemoveDialogs,
	RemoveCharDialog,
	NavigateToggle,
	Disconnect,
	CommerceEnd,
	BankEnd,
	CommerceInit,
	BankInit,
	UserCommerceInit,
	UserCommerceEnd,
	UserOfferConfirm,
	CommerceChat,
	ShowBlacksmithForm,
	ShowCarpenterForm,
	UpdateSta,
	UpdateMana,
	UpdateHP,
	UpdateGold,
	UpdateBankGold,
	UpdateExp,
	ChangeMap,
	PosUpdate,
	ChatOverHead,
	ConsoleMsg,
	GuildChat,
	ShowMessageBox,
	UserIndexInServer,
	UserCharIndexInServer,
	CharacterCreate,
	CharacterRemove,
	CharacterChangeNick,
	CharacterMove,
	ForceCharMove,
	CharacterChange,
	ObjectCreate,
	ObjectDelete,
	BlockPosition,
	PlayMIDI,
	PlayWave,
	GuildList,
	AreaChanged,
	PauseToggle,
	RainToggle,
	CreateFX,
	UpdateUserStats,
	WorkRequestTarget,
	ChangeInventorySlot,
	ChangeBankSlot,
	ChangeSpellSlot,
	Atributes,
	BlacksmithWeapons,
	BlacksmithArmors,
	CarpenterObjects,
	RestOK,
	ErrorMsg,
	Blind,
	Dumb,
	ShowSignal,
	ChangeNPCInventorySlot,
	UpdateHungerAndThirst,
	Fame,
	MiniStats,
	LevelUp,
	AddForumMsg,
	ShowForumForm,
	SetInvisible,
	DiceRoll,
	MeditateToggle,
	BlindNoMore,
	DumbNoMore,
	SendSkills,
	TrainerCreatureList,
	GuildNews,
	OfferDetails,
	AlianceProposalsList,
	PeaceProposalsList,
	CharacterInfo,
	GuildLeaderInfo,
	GuildMemberInfo,
	GuildDetails,
	ShowGuildFundationForm,
	ParalizeOK,
	ShowUserRequest,
	TradeOK,
	BankOK,
	ChangeUserTradeSlot,
	SendNight,
	Pong,
	UpdateTagAndStatus,
	
	#GM messages
	SpawnList,
	ShowSOSForm,
	ShowMOTDEditionForm,
	ShowGMPanelForm,
	UserNameList,
	ShowDenounces,
	RecordList,
	RecordDetails,

	ShowGuildAlign,
	ShowPartyForm,
	UpdateStrenghtAndDexterity,
	UpdateStrenght,
	UpdateDexterity,
	AddSlots,
	MultiMessage,
	StopWorking,
	CancelOfferItem
}

# ClientPacketID: Is the protocol from the client to the server
enum ClientPacketID {
	LoginExistingChar,
	ThrowDices,
	LoginNewChar,
	Talk,
	Yell,
	Whisper,
	Walk,
	RequestPositionUpdate,
	Attack,
	PickUp,
	SafeToggle,
	ResuscitationSafeToggle,
	RequestGuildLeaderInfo,
	RequestAtributes,
	RequestFame,
	RequestSkills,
	RequestMiniStats,
	CommerceEnd,
	UserCommerceEnd,
	UserCommerceConfirm,
	CommerceChat,
	BankEnd,
	UserCommerceOk,
	UserCommerceReject,
	Drop,
	CastSpell,
	LeftClick,
	DoubleClick,
	Work,
	UseSpellMacro,
	UseItem,
	CraftBlacksmith,
	CraftCarpenter,
	WorkLeftClick,
	CreateNewGuild,
	SpellInfo,
	EquipItem,
	ChangeHeading,
	ModifySkills,
	Train,
	CommerceBuy,
	BankExtractItem,
	CommerceSell,
	BankDeposit,
	ForumPost,
	MoveSpell,
	MoveBank,
	ClanCodexUpdate,
	UserCommerceOffer,
	GuildAcceptPeace,
	GuildRejectAlliance,
	GuildRejectPeace,
	GuildAcceptAlliance,
	GuildOfferPeace,
	GuildOfferAlliance,
	GuildAllianceDetails,
	GuildPeaceDetails,
	GuildRequestJoinerInfo,
	GuildAlliancePropList,
	GuildPeacePropList,
	GuildDeclareWar,
	GuildNewWebsite,
	GuildAcceptNewMember,
	GuildRejectNewMember,
	GuildKickMember,
	GuildUpdateNews,
	GuildMemberInfo,
	GuildOpenElections,
	GuildRequestMembership,
	GuildRequestDetails,
	Online,
	Quit,
	GuildLeave,
	RequestAccountState,
	PetStand,
	PetFollow,
	ReleasePet,
	TrainList,
	Rest,
	Meditate,
	Resucitate,
	Heal,
	Help,
	RequestStats,
	CommerceStart,
	BankStart,
	Enlist,
	Information,
	Reward,
	RequestMOTD,
	Uptime,
	PartyLeave,
	PartyCreate,
	PartyJoin,
	Inquiry,
	GuildMessage,
	PartyMessage,
	CentinelReport,
	GuildOnline,
	PartyOnline,
	CouncilMessage,
	RoleMasterRequest,
	GMRequest,
	BugReport,
	ChangeDescription,
	GuildVote,
	Punishments,
	ChangePassword,
	Gamble,
	InquiryVote,
	LeaveFaction,
	BankExtractGold,
	BankDepositGold,
	Denounce,
	GuildFundate,
	GuildFundation,
	PartyKick,
	PartySetLeader,
	PartyAcceptMember,
	Ping,
	RequestPartyForm,
	ItemUpgrade,
	GMCommands,
	InitCrafting,
	Home,
	ShowGuildNews,
	ShareNpc,
	StopSharingNpc,
	Consultation,
	MoveItem
}

enum EGMCommands {
	GM_MESSAGE = 1,           # /GMSG
	SHOW_NAME,                # /SHOWNAME
	ONLINE_ROYAL_ARMY,        # /ONLINEREAL
	ONLINE_CHAOS_LEGION,      # /ONLINECAOS
	GO_NEARBY,                # /IRCERCA
	COMMENT,                  # /REM
	SERVER_TIME,              # /HORA
	WHERE,                    # /DONDE
	CREATURES_IN_MAP,         # /NENE
	WARP_ME_TO_TARGET,        # /TELEPLOC
	WARP_CHAR,                # /TELEP
	SILENCE,                  # /SILENCIAR
	SOS_SHOW_LIST,            # /SHOW SOS
	SOS_REMOVE,               # SOSDONE
	GO_TO_CHAR,               # /IRA
	INVISIBLE,                # /INVISIBLE
	GM_PANEL,                 # /PANELGM
	REQUEST_USER_LIST,        # LISTUSU
	WORKING,                  # /TRABAJANDO
	HIDING,                   # /OCULTANDO
	JAIL,                     # /CARCEL
	KILL_NPC,                 # /RMATA
	WARN_USER,                # /ADVERTENCIA
	EDIT_CHAR,                # /MOD
	REQUEST_CHAR_INFO,        # /INFO
	REQUEST_CHAR_STATS,       # /STAT
	REQUEST_CHAR_GOLD,        # /BAL
	REQUEST_CHAR_INVENTORY,   # /INV
	REQUEST_CHAR_BANK,        # /BOV
	REQUEST_CHAR_SKILLS,      # /SKILLS
	REVIVE_CHAR,              # /REVIVIR
	ONLINE_GM,                # /ONLINEGM
	ONLINE_MAP,               # /ONLINEMAP
	FORGIVE,                  # /PERDON
	KICK,                     # /ECHAR
	EXECUTE,                  # /EJECUTAR
	BAN_CHAR,                 # /BAN
	UNBAN_CHAR,               # /UNBAN
	NPC_FOLLOW,               # /SEGUIR
	SUMMON_CHAR,              # /SUM
	SPAWN_LIST_REQUEST,       # /CC
	SPAWN_CREATURE,           # SPA
	RESET_NPC_INVENTORY,      # /RESETINV
	CLEAN_WORLD,              # /LIMPIAR
	SERVER_MESSAGE,           # /RMSG
	NICK_TO_IP,               # /NICK2IP
	IP_TO_NICK,               # /IP2NICK
	GUILD_ONLINE_MEMBERS,     # /ONCLAN
	TELEPORT_CREATE,          # /CT
	TELEPORT_DESTROY,         # /DT
	RAIN_TOGGLE,              # /LLUVIA
	SET_CHAR_DESCRIPTION,     # /SETDESC
	FORCE_MIDI_TO_MAP,        # /FORCEMIDIMAP
	FORCE_WAVE_TO_MAP,        # /FORCEWAVMAP
	ROYAL_ARMY_MESSAGE,       # /REALMSG
	CHAOS_LEGION_MESSAGE,     # /CAOSMSG
	CITIZEN_MESSAGE,          # /CIUMSG
	CRIMINAL_MESSAGE,         # /CRIMSG
	TALK_AS_NPC,              # /TALKAS
	DESTROY_ALL_ITEMS_IN_AREA,# /MASSDEST
	ACCEPT_ROYAL_COUNCIL_MEMBER, # /ACEPTCONSE
	ACCEPT_CHAOS_COUNCIL_MEMBER, # /ACEPTCONSECAOS
	ITEMS_IN_THE_FLOOR,       # /PISO
	MAKE_DUMB,                # /ESTUPIDO
	MAKE_DUMB_NO_MORE,        # /NOESTUPIDO
	DUMP_IP_TABLES,           # /DUMPSECURITY
	COUNCIL_KICK,             # /KICKCONSE
	SET_TRIGGER,              # /TRIGGER
	ASK_TRIGGER,              # /TRIGGER with no args
	BANNED_IP_LIST,           # /BANIPLIST
	BANNED_IP_RELOAD,         # /BANIPRELOAD
	GUILD_MEMBER_LIST,        # /MIEMBROSCLAN
	GUILD_BAN,                # /BANCLAN
	BAN_IP,                   # /BANIP
	UNBAN_IP,                 # /UNBANIP
	CREATE_ITEM,              # /CI
	DESTROY_ITEMS,            # /DEST
	CHAOS_LEGION_KICK,        # /NOCAOS
	ROYAL_ARMY_KICK,          # /NOREAL
	FORCE_MIDI_ALL,           # /FORCEMIDI
	FORCE_WAVE_ALL,           # /FORCEWAV
	REMOVE_PUNISHMENT,        # /BORRARPENA
	TILE_BLOCKED_TOGGLE,      # /BLOQ
	KILL_NPC_NO_RESPAWN,      # /MATA
	KILL_ALL_NEARBY_NPCS,     # /MASSKILL
	LAST_IP,                  # /LASTIP
	CHANGE_MOTD,              # /MOTDCAMBIA
	SET_MOTD,                 # ZMOTD
	SYSTEM_MESSAGE,           # /SMSG
	CREATE_NPC,               # /ACC
	CREATE_NPC_WITH_RESPAWN,  # /RACC
	IMPERIAL_ARMOUR,          # /AI1 - 4
	CHAOS_ARMOUR,             # /AC1 - 4
	NAVIGATE_TOGGLE,          # /NAVE
	SERVER_OPEN_TO_USERS_TOGGLE, # /HABILITAR
	TURN_OFF_SERVER,          # /APAGAR
	TURN_CRIMINAL,            # /CONDEN
	RESET_FACTIONS,           # /RAJAR
	REMOVE_CHAR_FROM_GUILD,   # /RAJARCLAN
	REQUEST_CHAR_MAIL,        # /LASTEMAIL
	ALTER_PASSWORD,           # /APASS
	ALTER_MAIL,               # /AEMAIL
	ALTER_NAME,               # /ANAME
	TOGGLE_CENTINEL_ACTIVATED,# /CENTINELAACTIVADO
	DO_BACKUP,                # /DOBACKUP
	SHOW_GUILD_MESSAGES,      # /SHOWCMSG
	SAVE_MAP,                 # /GUARDAMAPA
	CLEAN_SOS,                # /BORRAR SOS
	SHOW_SERVER_FORM,         # /SHOW INT
	NIGHT,                    # /NOCHE
	KICK_ALL_CHARS,           # /ECHARTODOSPJS
	RELOAD_NPCS,              # /RELOADNPCS
	RELOAD_SERVER_INI,        # /RELOADSINI
	RELOAD_SPELLS,            # /RELOADHECHIZOS
	RELOAD_OBJECTS,           # /RELOADOBJ
	RESTART,                  # /REINICIAR
	RESET_AUTO_UPDATE,        # /AUTOUPDATE
	CHAT_COLOR,               # /CHATCOLOR
	IGNORED,                  # /IGNORADO
	CHECK_SLOT,               # /SLOT
	SET_INI_VAR,              # /SETINIVAR LLAVE CLAVE VALOR
	CREATE_PRETORIAN_CLAN,    # /CREARPRETORIANOS
	REMOVE_PRETORIAN_CLAN,    # /ELIMINARPRETORIANOS
	ENABLE_DENOUNCES,         # /DENUNCIAS
	SHOW_DENOUNCES_LIST,      # /SHOW DENUNCIAS
	MAP_MESSAGE,              # /MAPMSG
	SET_DIALOG,               # /SETDIALOG
	IMPERSONATE,              # /IMPERSONAR
	IMITATE,                  # /MIMETIZAR
	RECORD_ADD,
	RECORD_REMOVE,
	RECORD_ADD_OBS,
	RECORD_LIST_REQUEST,
	RECORD_DETAILS_REQUEST
}
