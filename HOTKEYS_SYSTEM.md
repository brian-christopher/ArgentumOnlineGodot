# Sistema de Configuración de Hotkeys - Argentum Online Godot

## 🎮 Descripción General

Este sistema permite a los jugadores personalizar completamente las teclas del juego, adaptando la experiencia a su estilo de combate preferido. Ya sea que prefieras el clásico control con flechas o el moderno WASD, ¡el poder está en tus manos!

## 📁 Archivos del Sistema

### Core del Sistema
- `engine/autoload/hotkey_config.gd` - Sistema principal de gestión de hotkeys
- `ui/hub/hotkey_config_window.gd` - Ventana de configuración visual
- `ui/hub/hotkey_config_window.tscn` - Escena de la interfaz

### Integración
- `project.godot` - Configuración de input actions y autoload
- `ui/hub/options_window.gd` - Botón de acceso desde menú de opciones
- `ui/hub/hub_controller.gd` - Integración con el controlador principal

## 🎯 Características Implementadas

### ✅ Funcionalidades Principales
- **Reasignación completa de teclas** - Todas las acciones del juego son configurables
- **Sistema de categorías** - Organización intuitiva por tipo de acción
- **Validación automática** - Previene conflictos y teclas inválidas
- **Persistencia** - La configuración se guarda entre sesiones
- **Presets populares** - Configuraciones predefinidas (WASD, Flechas, Clásico)

### 🎨 Interfaz Intuitiva
- **Ventana modal** - Diseño limpio y fácil de usar
- **Detección de teclas** - Sistema visual para asignar nuevas teclas
- **Reset individual** - Restaurar teclas una por una
- **Reset total** - Volver a configuración por defecto

### 🔧 Categorías de Hotkeys

#### Movimiento
- Arriba/Abajo/Izquierda/Derecha (WASD por defecto)
- Compatible con flechas direccionales

#### Combate
- Atacar (Espacio)
- Equipar objeto (E)
- Usar objeto (U)
- Tirar objeto (T)

#### Inventario
- Recoger (A)
- Domar animal (D)
- Robar (R)

#### Comunicación
- Hablar (Enter)
- Hablar con clan (F1)

#### Habilidades
- Meditar (F5)
- Ocultarse (O)
- Refrescar estadísticas (L)
- Macro de hechizos (F7)

#### Sistema
- Salir (Escape)
- Captura de pantalla (F9)
- Modo seguro (*)
- Mostrar nombres (F2)
- Mostrar FPS (F3)

## 🚀 Uso del Sistema

### Acceder a la Configuración
1. Abrir el menú **Opciones** desde el juego
2. Hacer clic en el botón **"Configurar Teclas..."**
3. Navegar por las pestañas de categorías
4. Hacer clic en cualquier botón de tecla para reasignar
5. Presionar la nueva tecla deseada

### Presets Disponibles
- **WASD** - Configuración moderna para jugadores de FPS/MMO
- **Flechas** - Configuración clásica con teclas direccionales
- **Clásico** - Configuración original de Argentum Online

### Atajos en la Ventana
- **Clic en botón de tecla** - Comenzar reasignación
- **Botón ↺** - Resetear tecla individual
- **"Restablecer Todo"** - Resetear todas las teclas

## 🔌 Integración Técnica

### Autoload Global
```gdscript
# Acceso desde cualquier parte del juego
HotkeyConfig.set_hotkey("Attack", KEY_SPACE)
HotkeyConfig.get_hotkey("Meditate").current_key
```

### Señales del Sistema
```gdscript
# Detectar cambios de hotkeys
HotkeyConfig.hotkey_changed.connect(func(action, key): 
    print("Hotkey cambiado: ", action, " -> ", key)
)
```

### Persistencia
- Configuración guardada en `user://hotkeys.cfg`
- Carga automática al iniciar el juego
- Guardado instantáneo al cambiar teclas

## 🛠️ Extensión del Sistema

### Agregar Nuevas Acciones
```gdscript
# En hotkey_config.gd - _initialize_default_hotkeys()
_add_hotkey("NuevaAccion", "Nombre Visible", Categorias.COMBATE, 
           KEY_N, "Descripción de la acción")
```

### Agregar al project.godot
```ini
[NuevaAccion]
"deadzone": 0.2,
"events": [Object(InputEventKey,"resource_local_to_scene":false,...
```

### Manejar en el Controlador
```gdscript
# En hub_controller.gd - _handle_key_event()
if event.is_action_pressed("NuevaAccion"):
    # Tu lógica aquí
    pass
```

## ⚡ Optimizaciones y Buenas Prácticas

### Rendimiento
- Sistema de input optimizado con InputMap de Godot
- Detección eficiente de conflictos de teclas
- Carga asíncrona de configuración

### Validación
- Teclas modificadoras no permitidas como acciones individuales
- Prevención de duplicados en tiempo real
- Feedback visual inmediato

### UX/UI
- Diseño consistente con el resto del juego
- Tooltips descriptivos para cada acción
- Confirmación para acciones destructivas (reset total)

## 🐛 Solución de Problemas

### Issues Comunes
1. **Tecla no responde** - Verificar que no esté en conflicto con otra acción
2. **Configuración no se guarda** - Revisar permisos de escritura en user://
3. **Hotkey no funciona en juego** - Asegurar que esté en project.godot

### Debug Mode
Activar logs detallados:
```gdscript
# En hotkey_config.gd
print("[HotkeyConfig] Acción: ", action_name, " -> Tecla: ", key_code)
```

## 📜 Historial de Cambios

### v1.0 - Versión Inicial
- Sistema completo de configuración de hotkeys
- Interfaz visual intuitiva
- Integración con sistemas existentes
- Presets populares
- Persistencia completa

---

**¡Que los dioses de la guerra guíen tus dedos en batalla!** ⚔️🔥

*Desarrollado para la comunidad de Argentum Online Godot*
