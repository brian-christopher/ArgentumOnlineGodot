# Sistema de Offsets de Cabeza para Personajes

## Descripción del Sistema

El sistema de offsets de cabeza permite que diferentes tipos de personajes (humanos, elfos, enanos, gomos) tengan sus cabezas posicionadas correctamente según su anatomy. Esto es crucial para que los enanos y gomos tengan las cabezas más bajas que los humanos y elfos.

## Implementación en Visual Basic 6

### Estructuras de Datos Clave

```vb
' Estructura en Declares.bas
Public Type tIndiceCuerpo
    Body(1 To 4) As Integer      ' Grh indices para cada dirección
    HeadOffsetX As Integer        ' Offset X para la cabeza
    HeadOffsetY As Integer        ' Offset Y para la cabeza
End Type

' Estructura en TileEngine.bas
Public Type BodyData
    Walk(E_Heading.NORTH To E_Heading.WEST) As Grh
    HeadOffset As Position        ' Offset de cabeza aplicado
End Type
```

### Carga de Datos

```vb
Sub CargarCuerpos()
    ' Lee el archivo Personajes.ind
    For i = 1 To NumCuerpos
        Get #N, , MisCuerpos(i)
        
        ' Aplica los offsets a la estructura BodyData
        BodyData(i).HeadOffset.X = MisCuerpos(i).HeadOffsetX
        BodyData(i).HeadOffset.Y = MisCuerpos(i).HeadOffsetY
    Next i
End Sub
```

### Renderizado

```vb
' Dibuja la cabeza con el offset correspondiente
Call DDrawTransGrhtoSurface(.Head.Head(.Heading), _
    PixelOffsetX + .Body.HeadOffset.X, _
    PixelOffsetY + .Body.HeadOffset.Y, 1, 0)
```

## Implementación en Godot

### Estructuras de Datos

```gdscript
# common/data/grh_animation_data.gd
class_name GrhAnimationData
extends RefCounted

var north:int
var south:int
var east:int
var west:int

var offsetX:int    # Offset X para la cabeza
var offsetY:int    # Offset Y para la cabeza
```

### Carga de Datos

```gdscript
# engine/autoload/game_assets.gd
func _LoadBodiesData() -> void:
    var stream = StreamPeerBuffer.new()
    stream.data_array = FileAccess.get_file_as_bytes("res://Assets/Init/personajes.ind")
    
    # Lee el archivo binario
    for i in range(1, count + 1):
        var animation = GrhAnimationData.new()
        animation.north = stream.get_16()
        animation.east = stream.get_16()
        animation.south = stream.get_16()
        animation.west = stream.get_16()
        
        # Lee los offsets de cabeza
        animation.offsetX = stream.get_16()
        animation.offsetY = stream.get_16()
        
        BodyAnimationList[i] = animation
```

### Aplicación de Offsets en el Renderer

```gdscript
# engine/character/character_renderer.gd
func _set_body(id:int) -> void:
    _body = id
    _bodyAnimatedSprite.sprite_frames = _LoadSpriteFrames("res://Resources/Character/Bodies/body_%d.tres" % id)
    
    # Apply head offset for different body types (enanos, gomos, etc.)
    if id > 0 and id < GameAssets.BodyAnimationList.size():
        var body_data = GameAssets.BodyAnimationList[id]
        _headAnimatedSprite.position = Vector2(body_data.offsetX, body_data.offsetY)
        _helmetAnimatedSprite.position = Vector2(body_data.offsetX, body_data.offsetY)
```

## IDs de Cuerpos Conocidos

Según los datos originales de Argentum Online:

- **Humanos**: Cuerpos 1-20 (offsets estándar)
- **Elfos**: Cuerpos 21-33 (offsets ligeramente ajustados)
- **Enanos**: Cuerpos 34-40 (offsets con cabeza más baja)
- **Gomos**: Cuerpos 41-50 (offsets con cabeza significativamente más baja)

## Archivos de Datos

- `Assets/Init/personajes.ind` - Contiene los datos de cuerpos con offsets
- `Assets/Init/cabezas.ind` - Contiene los datos de cabezas
- `Resources/Character/Bodies/body_*.tres` - Recursos de animación de cuerpos

## Pruebas

Para probar el sistema, ejecuta el script `test_head_offsets.gd` que creará personajes de prueba con diferentes cuerpos para visualizar los offsets.

## Notas Importantes

1. Los offsets se aplican tanto a la cabeza como al casco
2. Los valores de offsetX y offsetY son en píxeles
3. Los valores negativos mueven la cabeza hacia arriba/izquierda
4. Los valores positivos mueven la cabeza hacia abajo/derecha
5. El sistema es compatible con el formato de datos original de VB6

## Problemas Comunes

- **Cabezas flotantes**: Verificar que los offsets se estén aplicando después de cargar el sprite del cuerpo
- **Cabezas en posición incorrecta**: Revisar los valores en el archivo `personajes.ind`
- **No se aplican los offsets**: Asegurarse que `GameAssets.BodyAnimationList` esté cargado antes de usarlo
