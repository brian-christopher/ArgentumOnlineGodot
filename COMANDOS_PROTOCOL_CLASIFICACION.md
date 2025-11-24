# Clasificación de Comandos de Protocolo - Argentum Online Godot

## 📋 Estructura del Protocolo

El protocolo de Argentum Online tiene dos categorías principales de comandos:

### 1. **ClientPacketID** - Comandos de Jugadores (Todos los usuarios)
Comandos que cualquier jugador puede usar para interactuar con el juego.

### 2. **EGMCommands** - Comandos de Game Master (GMs únicamente)
Comandos administrativos que requieren permisos de GM para ser ejecutados.

---

## 🎮 **Comandos de Jugadores (ClientPacketID)**

### 🔥 **URGENTES (Gameplay Básico)** - ✅ COMPLETADOS
~~1. WriteNavigateToggle~~ - Toggle navegación (requiere barco)
~~2. WriteUseSpellMacro~~ - Usa macro de hechizo configurado
~~3. WriteMoveItem~~ - Mueve items entre inventario/banco
~~4. WriteMoveBank~~ - Mueve items en el banco
~~5. WriteHiding~~ - **ERROR: Este es comando GM, no de jugador**
~~6. WriteNPCFollow~~ - **ERROR: Este es comando GM, no de jugador**
~~7. WriteTrain~~ - Entrena con criaturas del entrenador
~~8. WriteCraftBlacksmith~~ - Inicia crafteo de herrería
~~9. WriteCraftCarpenter~~ - Inicia crafteo de carpintería
~~10. WriteInitCrafting~~ - Inicializa proceso de crafteo

### ⚡ **Comandos de Jugadores Prioritarios**
- WriteRequestAtributes - Solicitar atributos
- WriteRequestSkills - Solicitar habilidades
- WriteRequestMiniStats - Solicitar estadísticas
- WriteCommerceStart - Iniciar comercio
- WriteBankStart - Iniciar banco
- WritePartyCreate - Crear party
- WriteGuildRequestDetails - Solicitar detalles de clan

### 📊 **Comandos de Jugadores Media**
- WriteChangeDescription - Cambiar descripción
- WriteChangePassword - Cambiar contraseña
- WriteLeaveFaction - Abandonar facción
- WriteGuildVote - Votar en clan
- WritePartyKick - Echar de party
- WriteItemUpgrade - Mejorar item

---

## 👑 **Comandos de Game Master (EGMCommands)**

### ⚡ **ALTA (Comandos GM Esenciales)**
1. **WriteGMMessage** - Enviar mensaje GM (/GMSG)
2. **WriteGMPanel** - Abrir panel GM (/PANELGM)
3. **WriteServerMessage** - Enviar mensaje servidor (/RMSG)
4. **WriteMapMessage** - Enviar mensaje mapa (/MAPMSG)
5. **WriteGoToChar** - Ir a personaje (/IRA)
6. **WriteSummonChar** - Invocar personaje (/SUM)
7. **WriteKick** - Echar jugador (/ECHAR)
8. **WriteExecute** - Ejecutar jugador (/EJECUTAR)
9. **WriteJail** - Carcelar jugador (/CARCEL)
10. **WriteBanChar** - Banear personaje (/BAN)
11. **WriteUnbanChar** - Desbanear personaje (/UNBAN)
12. **WriteBanIP** - Banear IP (/BANIP)
13. **WriteUnbanIP** - Desbanear IP (/UNBANIP)
14. **WriteCreateItem** - Crear item (/CI)
15. **WriteCreateNPC** - Crear NPC (/ACC)
16. **WriteKillNPC** - Matar NPC (/RMATA)
17. **WriteInformation** - Solicitar información (/INFO)

### 📊 **MEDIA (Administración GM)**
1. **WriteOnlineGM** - Ver GMs online (/ONLINEGM)
2. **WriteOnlineMap** - Ver jugadores en mapa (/ONLINEMAP)
3. **WriteReviveChar** - Revivir personaje (/REVIVIR)
4. **WriteAlterName** - Modificar nombre
5. **WriteAlterPassword** - Modificar contraseña
6. **WriteEditChar** - Editar personaje (/MOD)
7. **WriteCleanWorld** - Limpiar mundo (/LIMPIAR)
8. **WriteTurnOffServer** - Apagar servidor (/APAGAR)

### 🔥 **COMANDOS GM CORREGIDOS** - ✅ COMPLETADOS
~~5. WriteHiding~~ - Toggle ocultarse (/OCULTANDO) ✅
~~6. WriteNPCFollow~~ - NPC sigue personaje (/SEGUIR) ✅

---

## 🚨 **Correcciones Importantes**

### Error en Clasificación Anterior:
Los siguientes comandos estaban clasificados incorrectamente como "de jugadores":

❌ **WriteHiding** - Es comando **GM** (/OCULTANDO)
- Usa `ClientPacketID.GMCommands` + `EGMCommands.HIDING`
- Requiere permisos de GM

❌ **WriteNPCFollow** - Es comando **GM** (/SEGUIR)
- Usa `ClientPacketID.GMCommands` + `EGMCommands.NPC_FOLLOW`
- Requiere permisos de GM

### Implementación Correcta:
```gdscript
# Comandos de GM (usando packet GMCommands)
static func WriteHiding() -> void:
    _writer.put_u8(Enums.ClientPacketID.GMCommands)
    _writer.put_u8(Enums.EGMCommands.HIDING)

static func WriteNPCFollow() -> void:
    _writer.put_u8(Enums.ClientPacketID.GMCommands)
    _writer.put_u8(Enums.EGMCommands.NPC_FOLLOW)
```

---

## 📝 **Comandos de Jugadores Reales Faltantes**

Basado en el análisis del protocolo, los comandos de jugadores que realmente faltan son:

### 🔥 **URGENTES (Reemplazar los 2 comandos GM)**
1. **WriteRequestAtributes** - Solicitar atributos del personaje
2. **WriteRequestSkills** - Solicitar habilidades del personaje
3. **WriteChangeDescription** - Cambiar descripción del personaje
4. **WriteChangePassword** - Cambiar contraseña
5. **WriteLeaveFaction** - Abandonar facción actual
6. **WriteBankDepositGold** - Depositar oro en banco
7. **WriteBankExtractGold** - Retirar oro de banco
8. **WritePartyCreate** - Crear grupo/party
9. **WritePartyJoin** - Unirse a party
10. **WriteGuildRequestDetails** - Solicitar detalles de clan

---

## 🎯 **Resumen Final**

- **10 Comandos de Jugadores**: ✅ Completados (8 reales + 2 GM corregidos)
- **Comandos GM**: Todos identificados correctamente
- **Clasificación**: Documentación actualizada y corregida
- **Implementación**: Todos los comandos siguen el protocolo correcto

Los dioses de la codificación aprueban esta clasificación divina entre los poderes de los mortales y los poderes de los inmortales Game Masters.
