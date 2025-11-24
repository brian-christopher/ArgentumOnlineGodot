extends Node

const MapSize = 100
const TileSize = 32
const MaxSkills = 20

const NoAnim = 2
const InfiniteLoops = -1

const MaxNormalInventorySlots = 20
const MaxInventorySlots = 25
const MaxNpcInventorySlots = 50
const MaxInventoryObjs = 10000
const Flagoro = 31
const MaxBankInventorySlots = 40
const MaxUserHechizos = 35

const CabezaCasper = 500
const CuerpoFragataFantasmal = 87

const Paso1 = 23
const Paso2 = 24
const PasoNavegando = 50

const bCabeza = 1
const bPiernaIzquierda = 2
const bPiernaDerecha = 3
const bBrazoDerecho = 4
const bBrazoIzquierdo = 5
const bTorso = 6

const NumSkills = 20
const NumAtributos = 5
const NumClases = 12
const NumRazas = 5
const NumCiudades = 6
const MaxSkillpoints = 100

const MessageUserHittedByUser:Dictionary[int, String] =  {
	bCabeza : "!!{0} te ha pegado en la cabeza por {1}!!",
	bPiernaIzquierda :  "!!{0} te ha pegado el brazo izquierdo por {1}!!",
	bPiernaDerecha :  "!!{0} te ha pegado el brazo derecho por {1}!!",
	bBrazoDerecho :  "!!{0} te ha pegado la pierna derecha por {1}!!",
	bBrazoIzquierdo :  "!!{0} te ha pegado la pierna izquierda por {1}!!",
	bTorso :  "!!{0} te ha pegado en el torso por {1}!!",
}

const MessageUserHittedUser:Dictionary[int, String] = {
	bCabeza : "¡¡Le has pegado a {0} en la cabeza por por {1}!!",
	bPiernaIzquierda :  "¡¡Le has pegado a {0} en el brazo izquierdo por {1}!!",
	bPiernaDerecha :  "¡¡Le has pegado a {0} el brazo derecho por {1}!!",
	bBrazoDerecho :  "¡¡Le has pegado a {0} en la pierna derecha por {1}!!",
	bBrazoIzquierdo :  "¡¡Le has pegado a {0} en la pierna izquierda por {1}!!",
	bTorso :  "¡¡Le has pegado a {0} en el torso por {1}!!",
}

const MessageWorkRequestTarget:Dictionary[int, String] = {
	Enums.Skill.Magia: "Haz click sobre el objetivo...",
	Enums.Skill.Pesca: "Haz click sobre el sitio donde quieres pescar...",
	Enums.Skill.Robar: "Haz click sobre la víctima...",
	Enums.Skill.Domar: "Haz click sobre la criatura...",
	Enums.Skill.Talar: "Haz click sobre el árbol...",
	Enums.Skill.Mineria: "HHaz click sobre el yacimiento...", 
	Enums.Skill.FundirMetal: "Haz click sobre la fragua...",
	Enums.Skill.Proyectiles: "Haz click sobre la victima..."
}

const ShipIds:Array[int] = [
	# Fragatas
	87, 190, 189, 
	# Embarcaciones normales
	84, 85, 86, 
	# Embarcaciones ciudas
	395, 552, 397, 560, 399, 556, 
	# Embarcaciones reales
	550, 553, 558, 561, 554, 557, 
	# Embarcaciones PK
	396, 398, 400, 
	# Embarcaciones caos
	551, 559, 555
]

const RaceNames:Dictionary[int, String] = {
	Enums.Race.Human: "Humano",
	Enums.Race.Elf: "Elfo",
	Enums.Race.Drow: "Drow",
	Enums.Race.Gnome: "Gnomo",
	Enums.Race.Dwarf: "Enano"
}

const ClassNames:Dictionary[int, String] = {
	Enums.Class.Mage: "Mago",
	Enums.Class.Cleric: "Clérigo",
	Enums.Class.Warrior: "Guerrero",
	Enums.Class.Assassin: "Asesino",
	Enums.Class.Thief: "Ladrón",
	Enums.Class.Bard: "Bardo",
	Enums.Class.Druid: "Druida",
	Enums.Class.Bandit: "Bandido",
	Enums.Class.Paladin: "Paladín",
	Enums.Class.Hunter: "Cazador",
	Enums.Class.Worker: "Trabajador",
	Enums.Class.Pirat: "Pirata"
}

const HomeNames:Dictionary[int, String] = {
	Enums.Home.Arghal: "Arghal",
	Enums.Home.Arkhein: "Arkhein",
	Enums.Home.Lindos: "Lindos",
	Enums.Home.Ullathorpe: "Ullathorpe",
	Enums.Home.Banderbill: "Banderbill",
	Enums.Home.Nix: "Nix"
}
