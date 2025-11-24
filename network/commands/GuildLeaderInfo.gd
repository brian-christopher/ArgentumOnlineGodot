extends RefCounted
class_name GuildLeaderInfo

## Comando de red para recibir información del líder del clan
## Replica HandleGuildLeaderInfo del Protocol.bas VB6

var guild_names: Array = []
var guild_members: Array = []
var guild_news: String = ""
var guild_requests: Array = []

func _init(reader: StreamPeerBuffer = null) -> void:
	if reader: Deserialize(reader)

func Deserialize(reader: StreamPeerBuffer) -> void:
	print("[DEBUG] GuildLeaderInfo.Deserialize iniciado")
	
	# Leer lista de clanes como array directamente
	guild_names = Utils.GetUnicodeArrayString(reader)
	print("[DEBUG] guild_names count: ", guild_names.size())
	
	# Leer lista de miembros
	guild_members = Utils.GetUnicodeArrayString(reader)
	print("[DEBUG] guild_members count: ", guild_members.size())
	
	# Leer noticias del clan
	guild_news = Utils.GetUnicodeString(reader)
	print("[DEBUG] guild_news recibido, length: ", guild_news.length())
	
	# Leer lista de solicitudes
	guild_requests = Utils.GetUnicodeArrayString(reader)
	print("[DEBUG] guild_requests count: ", guild_requests.size())
	
	print("[DEBUG] GuildLeaderInfo.Deserialize completado exitosamente")
