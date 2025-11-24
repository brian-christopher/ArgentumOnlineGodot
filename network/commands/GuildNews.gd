extends RefCounted
class_name GuildNews

## Comando de red para recibir noticias del clan
## Replica HandleGuildNews del Protocol.bas VB6
## Parsea noticias, enemigos y aliados

var news: String = ""
var enemy_guilds: Array = []
var allied_guilds: Array = []

func _init(reader: StreamPeerBuffer = null) -> void:
	if reader: Deserialize(reader)

func Deserialize(reader: StreamPeerBuffer) -> void:
	# Leer noticias del clan
	news = Utils.GetUnicodeString(reader)
	
	# Leer lista de clanes enemigos (separados por SEPARATOR)
	enemy_guilds = Utils.GetUnicodeArrayString(reader)
	
	# Leer lista de clanes aliados (separados por SEPARATOR)
	allied_guilds = Utils.GetUnicodeArrayString(reader)
