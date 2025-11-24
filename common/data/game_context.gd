extends RefCounted
class_name GameContext

var playerInventory:Inventory = Inventory.new(Consts.MaxInventorySlots)
var merchantInventory:Inventory = Inventory.new(Consts.MaxNpcInventorySlots)
var bankInventory:Inventory = Inventory.new(Consts.MaxBankInventorySlots) 

var player_stats:PlayerStats = PlayerStats.new()
var tick_intervals:TickIntervals = TickIntervals.new()

# Datos del usuario
var player_level:int = 1
var player_gold:int = 0
var player_experience:int = 0
var player_experience_to_next_level:int = 0

var traveling:bool
var trading:bool
var pause:bool
var mirandoForo:bool

# Sistema de ping
var pingTime:int = 0
var userParalizado:bool
var userCiego:bool
var userEstupido:bool
var userDescansar:bool
var userMeditar:bool
var userNavegando:bool
var usingSkill:int

var player_map:int 
