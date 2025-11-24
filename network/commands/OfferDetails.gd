extends RefCounted
class_name OfferDetails

## Comando de red para recibir detalles de una propuesta (paz o alianza)
## Replica HandleOfferDetails del Protocol.bas VB6
## Muestra el texto completo de la propuesta

var details: String = ""

func _init(reader: StreamPeerBuffer = null) -> void:
	if reader: Deserialize(reader)

func Deserialize(stream: StreamPeerBuffer) -> void:
	details = Utils.GetUnicodeString(stream)
