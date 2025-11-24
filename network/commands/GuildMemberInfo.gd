extends RefCounted
class_name GuildMemberInfo

## Comando de red para recibir información de miembro de clan
## Replica HandleGuildMemberInfo del Protocol.bas VB6
## Se envía cuando el jugador tiene clan pero NO es líder

var guild_names: Array = []
var guild_members: Array = []

func _init(reader: StreamPeerBuffer = null) -> void:
	if reader: Deserialize(reader)

func Deserialize(reader: StreamPeerBuffer) -> void:
	# Leer lista de clanes (separados por SEPARATOR)
	guild_names = Utils.GetUnicodeArrayString(reader)
	
	# Leer lista de miembros del clan (separados por SEPARATOR)
	guild_members = Utils.GetUnicodeArrayString(reader)
