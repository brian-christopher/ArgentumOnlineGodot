extends RefCounted
class_name PeaceProposalsList

## Comando de red para recibir lista de propuestas de paz
## Replica HandlePeaceProposalsList del Protocol.bas VB6
## Lista de clanes que han propuesto paz

var guilds: Array = []

func _init(reader: StreamPeerBuffer = null) -> void:
	if reader: Deserialize(reader)

func Deserialize(reader: StreamPeerBuffer) -> void:
	var guilds_array = Utils.GetUnicodeArrayString(reader)
	guilds = guilds_array
