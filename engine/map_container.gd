extends Node2D
class_name MapContainer

const GridPositionKey = "GridPosition"

var _view:Node2D

var _characterCollection:Array[Character]
var _objectCollection:Array[Node2D]
var _tiles:PackedByteArray

func _ready() -> void:
	_tiles.resize(100 * 100)
	_tiles.fill(Enums.TileState.Blocked)  
	
func LoadMap(id:int) -> void:
	_DeleteEntities()
	
	if _view:
		_view.queue_free()
		
	_view = load("res://Maps/Map%d.tscn" % id).instantiate()
	_tiles = _view.get_meta("data")
	%MapView.add_child(_view)

func GetTile(x:int, y:int) -> int:
	return _tiles[x + y * 100]
	
func SetTile(x:int, y:int, state:int) -> void:
	_tiles[x + y * 100] = state
	
func BlockTile(x:int, y:int) -> void:
	var tile = GetTile(x, y) | Enums.TileState.Blocked
	SetTile(x, y, tile) 
		
func UnblockTile (x:int, y:int) -> void:
	var tile = GetTile(x, y) & ~Enums.TileState.Blocked
	SetTile(x, y, tile) 

func AddCharacter(character:Character) -> void:
	_characterCollection.append(character)
	_GetLayer("Layer3").add_child(character) 
		
func DeleteCharacter(instanceId:int) -> void:
	var character = GetCharacter(instanceId)
	if character:
		_characterCollection.erase(character)
		character.queue_free()
			
func GetCharacter(instanceId:int) -> Character:
	for node in _characterCollection:
		if node.instanceId == instanceId:
			return node
	return null
	
func GetCharacterAt(x:int, y:int) -> Character:
	for node in _characterCollection:
		if node.gridPosition == Vector2i(x, y):
			return node
	return null

func SetAllCharacterNamesVisible(names_visible:bool) -> void:
	for character in _characterCollection:
		character.SetNameVisible(names_visible)
	
func AddObject(grhId:int, x:int, y:int) -> void:
	if grhId > 0:
		if GameAssets.GrhDataList[grhId].frameCount > 1:
			grhId = GameAssets.GrhDataList[grhId].frames[1]
		
		var grhData = GameAssets.GrhDataList[grhId]
		var sprite = _CreateSprite(grhData, x -1, y - 1)
		sprite.set_meta(GridPositionKey, Vector2i(x, y))
		_objectCollection.append(sprite)
		
		if sprite.region_rect.size == Vector2(32, 32):
			_GetLayer("Layer2").add_child(sprite)
		else:
			_GetLayer("Layer3").add_child(sprite)
	
func DeleteObject(x:int, y:int) -> void:
	var node:Node2D = null
	
	for object in _objectCollection:
		if object.get_meta(GridPositionKey) == Vector2i(x, y):
			node = object
			break
	
	if node:
		_objectCollection.erase(node)
		node.queue_free()
	
func _DeleteEntities() -> void:
	_characterCollection.clear()
	_objectCollection.clear()

func _CreateSprite(grhData:GrhData, x:int, y:int) -> Sprite2D:
	var sprite = Sprite2D.new()
	sprite.texture = GameAssets.GetTexture(grhData.fileId)
	sprite.position = Vector2((x * 32) + 16, (y * 32) + 32);
	sprite.region_enabled = true
	sprite.region_rect = grhData.region;
	sprite.offset = Vector2(0, -sprite.region_rect.size.y / 2);
	
	return sprite

func _GetLayer(layerName: String) -> Node2D:

	for node in _view.get_children():
		if node.name == layerName: 
			return node
			
	push_error("MapContainer: layer %s not found" % layerName)
	return null
