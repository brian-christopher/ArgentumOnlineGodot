extends Node2D
class_name Character

const Speed = 120.0
const OUTLINE_SHADER = preload("res://shaders/outline.gdshader")
const SHIP_NAME_OFFSET_Y = 14.0
 
@onready var renderer: CharacterRenderer = $Renderer  
@onready var effect: CharacterEffect = $CharacterEffect

@export var _dialogLabel:Label
@export var _dialogShadowLabel:Label
@export var _nameLabel:Label
@export var _dialogClearTimer:Timer
@export var _dialogTypeTimer:Timer

var _pasoDerecho:bool
var _targetPosition:Vector2
var _charInvisible:bool
var _isPlayer:bool = false
var _shipFloatTime:float = 0.0
var _originalRendererPosition:Vector2
var _originalNameLabelPosition:Vector2

var _currentDialogText:String = ""
var _currentDialogColor:Color
var _isTypingDialog:bool = false

var instanceId:int
var gridPosition:Vector2i
var isMoving:bool
var priv:int

func _ready() -> void:
	Global.connect("dialog_font_size_changed", Callable(self, "_on_dialog_font_size_changed"))
	Global.connect("name_font_size_changed", Callable(self, "_on_name_font_size_changed"))
	Global.connect("player_names_visibility_changed", Callable(self, "_on_player_names_visibility_changed"))
	Global.connect("animated_dialog_changed", Callable(self, "_on_animated_dialog_changed"))
	# Guardar la posición original después de un pequeño delay para que se apliquen todas las correcciones
	call_deferred("_initialize_original_position")
	if _isPlayer:
		_apply_outline_effect()
	
	# Configurar el timer de tipografía
	if _dialogTypeTimer:
		_dialogTypeTimer.timeout.connect(_OnDialogTypeTimerTimeout)

func _physics_process(delta: float) -> void:
	_ProcessAnimation()
	_ProcessMovement(delta)
	_ProcessShipFloating(delta)
	_UpdateNameLabelPosition()

func SetAsPlayer(isPlayer: bool = true) -> void:
	_isPlayer = isPlayer
	if isPlayer and is_inside_tree():
		_apply_outline_effect()

func _initialize_original_position() -> void:
	_originalRendererPosition = renderer.position
	_originalNameLabelPosition = _nameLabel.position

func IsPlayer() -> bool:
	return _isPlayer

# Para usar en el futuro
func _apply_outline_effect() -> void:
	return 
	for child in renderer.get_children():
		if child is AnimatedSprite2D:
			var outline_material = ShaderMaterial.new()
			outline_material.shader = OUTLINE_SHADER
			# Configurar el color y ancho del borde
			outline_material.set_shader_parameter("outline_color", Color(0.0, 0.5, 1.0, 0.7))  # Azul con transparencia
			outline_material.set_shader_parameter("outline_width", 2.0)
			child.material = outline_material

func GetCharacterInvisible() -> bool:
	return _charInvisible
	
func SetCharacterInvisible(v:bool) -> void:
	_charInvisible = v
	renderer.visible = v
	_nameLabel.visible = v

func MoveTo(heading:int) -> void:
	if isMoving:
		position = _targetPosition
		isMoving = false
	
	var offset = Utils.HeadingToVector(heading)
	isMoving = true
	_targetPosition = position + (offset * Consts.TileSize)
	
func StopMoving() -> void:
	if isMoving:
		position = _targetPosition
	isMoving = false
 
func GetBoundaries() -> Rect2:
	return Rect2(global_position.x - 16, global_position.y - 64, 32, 64)
		
func SetCharacterName(text:String) -> void:
	_nameLabel.text = text
	_nameLabel.label_settings.font_size = Global.nameFontSize
	
func SetCharacterNameColor(color:Color) -> void:
	_nameLabel.self_modulate = color

func SetNameVisible(name_visible:bool) -> void:
	_nameLabel.visible = name_visible

func GetCharacterName() -> String:
	return _nameLabel.text

func IsDead() -> bool:
	return renderer.head in [Consts.CabezaCasper, Consts.CuerpoFragataFantasmal]
	
func IsNavigating() -> bool:
	return renderer.body in Consts.ShipIds
	
func PlayWalkSound() -> void:
	_pasoDerecho = !_pasoDerecho
	AudioManager.PlayAudio(Consts.Paso1 if _pasoDerecho else Consts.Paso2)
	
func PlayNavigationSound() -> void:
	AudioManager.PlayAudio(Consts.PasoNavegando, false, true)  # prevent_overlap = true

func Say(text:String, color:Color) -> void:
	# Cancelar cualquier animación anterior
	if _isTypingDialog:
		_stop_dialog_typing()
	
	# Guardar el texto completo y el color
	_currentDialogText = text
	_currentDialogColor = color
	
	# Configurar las etiquetas
	_dialogLabel.label_settings.font_size = Global.dialogFontSize
	_dialogShadowLabel.label_settings.font_size = _dialogLabel.label_settings.font_size
	_dialogLabel.modulate = color
	
	# Iniciar la animación de tipografía
	_start_dialog_typing()

func _OnDialogClearTimerTimeout() -> void:
	_stop_dialog_typing()
	_dialogLabel.text = ""
	_dialogShadowLabel.text = ""

func _start_dialog_typing() -> void:
	if _currentDialogText.is_empty():
		return
	
	# Si el diálogo animado está desactivado, mostrar todo de una vez (instantáneo)
	if not Global.animatedDialog:
		_dialogLabel.text = _currentDialogText
		_dialogShadowLabel.text = _currentDialogText
		_dialogClearTimer.start()
		return
	
	_isTypingDialog = true
	_dialogLabel.text = ""
	_dialogShadowLabel.text = ""
	
	# Iniciar el timer de tipografía
	_dialogTypeTimer.wait_time = Global.DIALOG_TYPING_SPEED
	_dialogTypeTimer.start()

func _stop_dialog_typing() -> void:
	_isTypingDialog = false
	if _dialogTypeTimer:
		_dialogTypeTimer.stop()

func _OnDialogTypeTimerTimeout() -> void:
	if not _isTypingDialog:
		return
	
	var current_length = _dialogLabel.text.length()
	var target_length = _currentDialogText.length()
	
	if current_length < target_length:
		# Agregar la siguiente letra
		var next_char_index = current_length
		var _next_char = _currentDialogText[next_char_index]
		
		# Construir el texto hasta el siguiente carácter
		var new_text = _currentDialogText.substr(0, next_char_index + 1)
		
		# Actualizar ambas etiquetas con el nuevo texto
		# Esto permite que el autowrap funcione correctamente
		_dialogLabel.text = new_text
		_dialogShadowLabel.text = new_text
		
		# Continuar la animación
		_dialogTypeTimer.start()
	else:
		# Animación completada - ahora iniciar el timer de limpieza
		_isTypingDialog = false
		_dialogClearTimer.start()
	
func _ProcessAnimation() -> void:
	if isMoving:
		renderer.Play()
	else:
		renderer.Stop()

func _ProcessMovement(delta:float) -> void:
	if !isMoving:
		return
	
	position = position.move_toward(_targetPosition, Speed * delta)
	if position == _targetPosition:
		isMoving = false

func _ProcessShipFloating(delta:float) -> void:
	# Solo aplicar animación de flotación si estamos en una barca y no nos estamos moviendo
	if !IsNavigating() or isMoving:
		# Si no es una barca o se está moviendo, restaurar posición original
		if renderer.position != _originalRendererPosition:
			renderer.position = _originalRendererPosition
			_shipFloatTime = 0.0
		return
	
	# Para barcas, la posición original debe ser más alta para compensar la flotación
	# Cuando está en barca, el personaje debe estar sobre la barca, no flotando debajo
	var ship_base_position = _originalRendererPosition + Vector2(0, -2)  # Compensar 2 píxeles hacia arriba
	
	# Animación de flotación suave para barcas
	_shipFloatTime += delta * 2.0  # Velocidad de flotación
	var float_offset = sin(_shipFloatTime) * 2.0  # 2 píxeles de amplitud
	renderer.position = ship_base_position + Vector2(0, float_offset)

func _UpdateNameLabelPosition() -> void:
	var target_position = _originalNameLabelPosition
	if IsNavigating():
		target_position = _originalNameLabelPosition + Vector2(0, SHIP_NAME_OFFSET_Y)
	_nameLabel.position = target_position

func _on_dialog_font_size_changed(value: int) -> void:
	_dialogLabel.label_settings.font_size = value
	_dialogShadowLabel.label_settings.font_size = value

func _on_name_font_size_changed(value: int) -> void:
	_nameLabel.label_settings.font_size = value

func _on_player_names_visibility_changed(names_visible: bool) -> void:
	SetNameVisible(names_visible)

func _on_animated_dialog_changed(animated: bool) -> void:
	# Si se desactiva la animación y está en medio de una, mostrar todo instantáneamente
	if not animated and _isTypingDialog:
		_stop_dialog_typing()
		_dialogLabel.text = _currentDialogText
		_dialogShadowLabel.text = _currentDialogText
		_dialogClearTimer.start()
