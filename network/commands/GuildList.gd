extends RefCounted
class_name GuildList

## Comando de red para recibir lista de clanes
## Replica HandleGuildList del Protocol.bas VB6
## Se envía cuando el jugador NO tiene clan

var guilds: Array = []

func _init(reader: StreamPeerBuffer = null) -> void:
	if reader: Deserialize(reader)

func Deserialize(reader: StreamPeerBuffer) -> void:
	guilds = Utils.GetUnicodeArrayString(reader)
