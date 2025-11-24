extends RefCounted
class_name GuildDetails

## Comando de red para recibir detalles de un clan
## Replica HandleGuildDetails del Protocol.bas VB6
## Incluye toda la información pública y privada del clan

var guild_name: String = ""
var founder: String = ""
var creation_date: String = ""
var leader: String = ""
var website: String = ""
var members_count: int = 0
var elections_open: bool = false
var alignment: String = ""
var enemies_count: int = 0
var allies_count: int = 0
var anti_faction: String = ""
var codex: Array = []
var description: String = ""
var is_leader: bool = false

func _init(reader: StreamPeerBuffer = null) -> void:
	if reader: Deserialize(reader)

func Deserialize(reader: StreamPeerBuffer) -> void:
	guild_name = Utils.GetUnicodeString(reader)
	founder = Utils.GetUnicodeString(reader)
	creation_date = Utils.GetUnicodeString(reader)
	leader = Utils.GetUnicodeString(reader)
	website = Utils.GetUnicodeString(reader)
	members_count = reader.get_16()
	elections_open = reader.get_u8() != 0
	alignment = Utils.GetUnicodeString(reader)
	enemies_count = reader.get_16()
	allies_count = reader.get_16()
	anti_faction = Utils.GetUnicodeString(reader)
	
	# Leer códex (8 líneas separadas por SEPARATOR)
	codex = Utils.GetUnicodeArrayString(reader)
	
	# Asegurar que el array tenga 8 elementos
	while codex.size() < 8:
		codex.append("")
	
	description = Utils.GetUnicodeString(reader)
