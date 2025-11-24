extends RefCounted
class_name TrainerCreatureList

## Comando de red para recibir lista de criaturas de entrenamiento
## Replica HandleTrainerCreatureList del Protocol.bas VB6
## Se envía cuando el jugador pide entrenar con un NPC maestro

var creatures: Array[String] = []

func _init(reader: StreamPeerBuffer = null) -> void:
	if reader: Deserialize(reader)

func Deserialize(reader: StreamPeerBuffer) -> void:
	var creatures_string: Array[String] = Utils.GetUnicodeArrayString(reader)

	creatures = creatures_string
