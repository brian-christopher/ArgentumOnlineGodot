# Comandos del Protocolo Cliente Faltantes en Godot

## Resumen
- **Total VB6**: 269 comandos Write
- **Total Godot**: 103 comandos Write
- **Faltantes**: ~166 comandos

## Comandos Faltantes por Categoría

### 🔴 CRÍTICOS - Funcionalidad Básica del Juego
```
WriteNavigateToggle          # Toggle navegación en barco
WriteUseSpellMacro          # Usar macro de hechizo
WriteMoveItem               # Mover items en inventario
WriteMoveBank               # Mover items en banco
WriteHiding                 # Ocultarse
WriteHome                   # Comando /HOGAR
WriteImitate                # Imitar
WriteForumPost              # Postear en foro
WriteNPCFollow              # NPC seguir
WriteSpawnCreature          # Spawnear criatura
WriteTrain                  # Entrenar con maestro
WriteCraftBlacksmith        # Craftear herrero
WriteCraftCarpenter         # Craftear carpintero
WriteInitCrafting           # Iniciar crafteo
```

### 🟡 IMPORTANTES - Comandos GM
```
WriteGMMessage              # Mensaje GM
WriteGMPanel                # Panel GM
WriteServerMessage          # Mensaje del servidor
WriteSystemMessage          # Mensaje del sistema
WriteMapMessage             # Mensaje al mapa
WriteCitizenMessage         # Mensaje a ciudadanos
WriteCriminalMessage        # Mensaje a criminales
WriteChaosLegionMessage     # Mensaje a legión del caos
WriteRoyalArmyMessage       # Mensaje a armada real
WriteTalkAsNPC              # Hablar como NPC

WriteGoToChar               # Ir a personaje
WriteGoNearby               # Ir cerca
WriteSummonChar             # Invocar personaje
WriteWarpChar               # Warpear personaje (ya existe como WriteTeleportChar)
WriteSpawnListRequest       # Solicitar lista de spawns

WriteKick                   # Kickear jugador
WriteExecute                # Ejecutar jugador
WriteJail                   # Encarcelar
WriteBanChar                # Banear personaje
WriteUnbanChar              # Desbanear personaje
WriteBanIP                  # Banear IP
WriteUnbanIP                # Desbanear IP
WriteForgive                # Perdonar
WriteTurnCriminal           # Volver criminal

WriteCreateItem             # Crear item
WriteDestroyItems           # Destruir items
WriteDestroyAllItemsInArea  # Destruir todos los items en área
WriteCreateNPC              # Crear NPC
WriteCreateNPCWithRespawn   # Crear NPC con respawn
WriteKillNPC                # Matar NPC
WriteKillNPCNoRespawn       # Matar NPC sin respawn
WriteKillAllNearbyNPCs      # Matar todos los NPCs cercanos
WriteResetNPCInventory      # Resetear inventario NPC
WriteRemoveNPC              # Remover NPC

WriteInformation            # Información de personaje (/INFO)
WriteRequestCharInfo        # Solicitar info de personaje
WriteRequestCharStats       # Solicitar stats de personaje
WriteRequestCharGold        # Solicitar oro de personaje
WriteRequestCharInventory   # Solicitar inventario de personaje
WriteRequestCharBank        # Solicitar banco de personaje
WriteRequestCharSkills      # Solicitar skills de personaje
WriteRequestCharMail        # Solicitar mail de personaje

WriteAlterName              # Alterar nombre
WriteAlterPassword          # Alterar contraseña
WriteAlterMail              # Alterar mail
WriteReviveChar             # Revivir personaje
WriteOnlineGM               # GMs online
WriteOnlineMap              # Jugadores online en mapa
WriteOnlineChaosLegion      # Legión del caos online
WriteOnlineRoyalArmy        # Armada real online
WriteCheckSlot              # Verificar slot

WriteMakeDumb               # Hacer estúpido
WriteMakeDumbNoMore         # Quitar estúpido
WriteSilence                # Silenciar
WriteWarnUser               # Advertir usuario
WriteEditChar               # Editar personaje

WriteSetCharDescription     # Establecer descripción
WriteChangeDescription      # Cambiar descripción (duplicado?)
WriteSetDialog              # Establecer diálogo
WriteImpersonate            # Impersonar
WriteImperialArmour         # Armadura imperial
WriteChaosArmour            # Armadura del caos

WriteAcceptRoyalCouncilMember    # Aceptar miembro consejo real
WriteAcceptChaosCouncilMember    # Aceptar miembro consejo caos
WriteCouncilKick                 # Kickear del consejo
WriteRoyalArmyKick               # Kickear de armada real
WriteChaosLegionKick             # Kickear de legión del caos
WriteResetFactions               # Resetear facciones

WriteRemoveCharFromGuild    # Remover personaje del clan
WriteRequestGuildMemberList # Solicitar lista de miembros del clan (falta?)
WriteGuildOnlineMembers     # Miembros del clan online (falta?)

WriteShowName               # Mostrar nombre
WriteShowServerForm         # Mostrar formulario del servidor
WriteNight                  # Hacer de noche
WriteKickAllChars           # Kickear todos los personajes
WriteReloadNPCs             # Recargar NPCs
WriteReloadServerIni        # Recargar server.ini
WriteReloadObjects          # Recargar objetos
WriteReloadSpells           # Recargar hechizos
WriteRestart                # Reiniciar servidor
WriteSaveChars              # Guardar personajes
WriteSaveMap                # Guardar mapa
WriteCleanWorld             # Limpiar mundo
WriteCleanSOS               # Limpiar SOS
WriteShowDenouncesList      # Mostrar lista de denuncias
WriteSOSShowList            # Mostrar lista SOS
WriteSOSRemove              # Remover SOS
WriteEnableDenounces        # Habilitar denuncias
WriteTurnOffServer          # Apagar servidor
WriteServerOpenToUsersToggle # Toggle servidor abierto
WriteServerTime             # Tiempo del servidor
WriteSetMOTD                # Establecer MOTD
WriteChangeMOTD             # Cambiar MOTD

WriteSetTrigger             # Establecer trigger
WriteAskTrigger             # Preguntar trigger
WriteTileBlockedToggle      # Toggle tile bloqueado
WriteToggleCentinelActivated # Toggle centinela activado
WriteRainToggle             # Toggle lluvia
WriteForceMIDIAll           # Forzar MIDI a todos
WriteForceMIDIToMap         # Forzar MIDI al mapa
WriteForceWAVEAll           # Forzar WAVE a todos
WriteForceWAVEToMap         # Forzar WAVE al mapa

WriteChangeMapInfoPK        # Cambiar info mapa PK
WriteChangeMapInfoBackup    # Cambiar info mapa backup
WriteChangeMapInfoRestricted # Cambiar info mapa restringido
WriteChangeMapInfoNoMagic   # Cambiar info mapa sin magia
WriteChangeMapInfoNoInvi    # Cambiar info mapa sin invisibilidad
WriteChangeMapInfoNoResu    # Cambiar info mapa sin resurrección
WriteChangeMapInfoLand      # Cambiar info mapa terreno
WriteChangeMapInfoZone      # Cambiar info mapa zona
WriteChangeMapInfoStealNpc  # Cambiar info mapa robar NPC
WriteChangeMapInfoNoOcultar # Cambiar info mapa sin ocultar
WriteChangeMapInfoNoInvocar # Cambiar info mapa sin invocar

WriteTeleportCreate         # Crear teletransporte
WriteTeleportDestroy        # Destruir teletransporte
WriteRainToggle             # Toggle lluvia
WriteSetIniVar              # Establecer variable INI
WriteCreatePretorianClan    # Crear clan pretoriano
WriteDeletePretorianClan    # Eliminar clan pretoriano
WriteDoBackup               # Hacer backup
WriteComment                # Comentario
WriteServerTime             # Tiempo del servidor
WriteWhere                  # Dónde está (comando /DONDE)
WriteCreaturesInMap         # Criaturas en mapa
WriteItemsInTheFloor        # Items en el piso
WriteCouncilMessage         # Mensaje al consejo
WriteChatColor              # Color del chat
WriteIgnored                # Ignorados
WriteCheckSlot              # Verificar slot
WriteResetAutoUpdate        # Resetear auto-update
WriteItemUpgrade            # Mejorar item
WriteCommerceChat           # Chat de comercio
WriteUserCommerceOffer      # Ofrecer en comercio de usuario
WriteUserCommerceConfirm    # Confirmar comercio de usuario (ya existe)
WriteUserCommerceEnd        # Terminar comercio de usuario (ya existe)
WriteUserCommerceOk         # OK comercio de usuario (ya existe)
WriteUserCommerceReject     # Rechazar comercio de usuario (ya existe)
WriteShowGuildMessages      # Mostrar mensajes del clan
WriteRequestUserList        # Solicitar lista de usuarios
WriteWorking                # Trabajando
WriteInvisible              # Invisible
WriteRequestPartyForm       # Solicitar formulario de party (ya existe)
WritePunishments            # Castigos (ya existe)
WriteRemovePunishment       # Remover castigo
WriteRecordListRequest      # Solicitar lista de récords
WriteRecordDetailsRequest   # Solicitar detalles de récord
WriteRecordRemove           # Remover récord
WriteRecordAdd              # Agregar récord
WriteRecordAddObs           # Agregar observación a récord
WriteIPToNick               # IP a nick
WriteNickToIP               # Nick a IP
WriteLastIP                 # Última IP
WriteDumpIPTables           # Volcar tablas IP
WriteBannedIPList           # Lista de IPs baneadas
WriteBannedIPReload         # Recargar IPs baneadas
WriteGuildBan               # Banear del clan
WriteUpTime                 # Uptime (ya existe)
```

### 🟢 YA IMPLEMENTADOS (Ejemplos)
```
✓ WriteLoginExistingChar (como WriteLoginExistingCharacter)
✓ WriteLoginNewChar
✓ WriteTalk
✓ WriteYell
✓ WriteWhisper
✓ WriteWalk
✓ WriteAttack
✓ WritePickUp (como WritePickup)
✓ WriteCastSpell
✓ WriteDoubleClick
✓ WriteDrop
✓ WriteEquipItem
✓ WriteUseItem
✓ WriteRequestPositionUpdate
✓ WriteRequestAtributes
✓ WriteRequestFame
✓ WriteRequestSkills
✓ WriteRequestStats
✓ WriteRequestMiniStats
✓ WriteMeditate
✓ WriteRest
✓ WriteHeal
✓ WriteHelp
✓ WriteQuit
✓ WriteChangeHeading
✓ WriteChangePassword
✓ WriteSafeToggle
✓ WriteResuscitationToggle
✓ WritePetFollow
✓ WritePetStand
✓ WriteReleasePet
✓ WriteThrowDice (como WriteThrowDice)
✓ WriteWork
✓ WriteWorkLeftClick
✓ WriteLeftClick
✓ WriteBankStart
✓ WriteBankEnd
✓ WriteBankDepositGold
✓ WriteBankExtractGold
✓ WriteBankDepositItem (como WriteBankDepositItem)
✓ WriteBankExtractItem
✓ WriteCommerceStart
✓ WriteCommerceEnd
✓ WriteCommerceBuy
✓ WriteCommerceSell
✓ WriteGamble
✓ WriteEnlist
✓ WriteLeaveFaction
✓ WriteRequestGuildLeaderInfo
✓ WriteGuildMessage
✓ WriteGuildOnline
✓ WriteGuildRequestJoinerInfo
✓ WriteGuildAlliancePropList
✓ WriteGuildPeacePropList
✓ WriteGuildRequestDetails
✓ WriteGuildRequestMembership
✓ WriteGuildAcceptNewMember
✓ WriteGuildRejectNewMember
✓ WriteGuildKickMember
✓ WriteGuildUpdateNews
✓ WriteGuildMemberInfo
✓ WriteGuildOpenElections
✓ WriteGuildAcceptPeace
✓ WriteGuildRejectPeace
✓ WriteGuildAcceptAlliance
✓ WriteGuildRejectAlliance
✓ WriteGuildOfferPeace
✓ WriteGuildAllianceDetails
✓ WriteGuildPeaceDetails
✓ WriteGuildOfferAlliance
✓ WriteGuildDeclareWar
✓ WriteGuildNewWebsite
✓ WriteGuildLeave
✓ WriteGuildVote
✓ WriteGuildFundation
✓ WriteGuildFundate
✓ WriteCreateNewGuild (como WriteCreateNewGuild)
✓ WriteClanCodexUpdate
✓ WritePartyCreate
✓ WritePartyJoin
✓ WritePartyLeave
✓ WritePartyKick
✓ WritePartySetLeader
✓ WritePartyAcceptMember
✓ WritePartyOnline
✓ WritePartyMessage
✓ WriteInquiry
✓ WriteInquiryVote
✓ WriteGMRequest
✓ WriteBugReport
✓ WriteConsultation
✓ WriteMoveSpell
✓ WriteCentinelReport
✓ WriteRequestMOTD
✓ WriteRequestAccountState
✓ WriteResucitate
✓ WriteReward
✓ WriteRoleMasterRequest
✓ WriteShareNpc
✓ WriteStopSharingNpc
✓ WriteConsultation
✓ WriteSpellInfo
✓ WritePunishments
✓ WriteTrainList
✓ WriteRest
✓ WriteModifySkills
✓ WriteShowGuildNews
✓ WritePing
✓ WriteUpTime
✓ WriteWarpChar (como WriteTeleportChar)
✓ WriteWarpMeToTarget
✓ WriteCouncilMessage
```

## Prioridades de Implementación

### 🔥 URGENTE (Gameplay Básico)
~~1. WriteNavigateToggle~~ ✅ (Comando GM - /NAVE)
~~2. WriteUseSpellMacro~~ ✅ (Comando Jugador)
~~3. WriteMoveItem~~ ✅ (Comando Jugador)
~~4. WriteMoveBank~~ ✅ (Comando Jugador)
~~5. WriteHiding~~ ✅ (Comando GM - /OCULTANDO)
~~6. WriteNPCFollow~~ ✅ (Comando GM - /SEGUIR)
~~7. WriteTrain~~ ✅ (Comando Jugador)
~~8. WriteCraftBlacksmith~~ ✅ (Comando Jugador)
~~9. WriteCraftCarpenter~~ ✅ (Comando Jugador)
~~10. WriteInitCrafting~~ ✅ (Comando Jugador)

**Nota**: 8 comandos de jugadores + 2 comandos GM implementados correctamente

### ⚡ ALTA (Comandos GM Esenciales)
1. WriteGMMessage
2. WriteGMPanel
3. WriteServerMessage
4. WriteMapMessage
5. WriteGoToChar
6. WriteSummonChar
7. WriteKick
8. WriteExecute
9. WriteJail
10. WriteBanChar / WriteUnbanChar
11. WriteBanIP / WriteUnbanIP
12. WriteCreateItem
13. WriteCreateNPC
14. WriteKillNPC
15. WriteInformation

### 📊 MEDIA (Administración)
1. WriteOnlineGM
2. WriteOnlineMap
3. WriteReviveChar
4. WriteAlterName
5. WriteAlterPassword
6. WriteEditChar
7. WriteReloadNPCs
8. WriteSaveChars
9. WriteCleanWorld
10. WriteTurnOffServer

### 📝 BAJA (Funcionalidades Avanzadas)
1. WriteChangeMapInfo* (todas las variantes):
   - WriteChangeMapInfoPK
   - WriteChangeMapInfoBackup
   - WriteChangeMapInfoRestricted
   - WriteChangeMapInfoNoMagic
   - WriteChangeMapInfoNoInvi
   - WriteChangeMapInfoNoResu
   - WriteChangeMapInfoLand
   - WriteChangeMapInfoZone
   - WriteChangeMapInfoStealNpc
   - WriteChangeMapInfoNoOcultar
   - WriteChangeMapInfoNoInvocar
2. WriteTeleportCreate
3. WriteTeleportDestroy
4. WriteRecordListRequest
5. WriteRecordDetailsRequest
6. WriteRecordRemove
7. WriteRecordAdd
8. WriteRecordAddObs
9. WriteIPToNick
10. WriteNickToIP
11. WriteLastIP
12. WriteDumpIPTables
13. WriteBannedIPList
14. WriteBannedIPReload
15. WriteGuildBan
16. WriteSetIniVar
17. WriteCreatePretorianClan
18. WriteDeletePretorianClan
19. WriteDoBackup
20. WriteComment
21. WriteWhere
22. WriteCreaturesInMap
23. WriteItemsInTheFloor
24. WriteChatColor
25. WriteIgnored
26. WriteCheckSlot
27. WriteResetAutoUpdate
28. WriteItemUpgrade
29. WriteCommerceChat
30. WriteUserCommerceOffer
31. WriteShowGuildMessages
32. WriteRequestUserList
33. WriteWorking
34. WriteInvisible
35. WriteRemovePunishment
36. WriteSetCharDescription
37. WriteSetDialog
38. WriteImpersonate
39. WriteImperialArmour
40. WriteChaosArmour
41. WriteAcceptRoyalCouncilMember
42. WriteAcceptChaosCouncilMember
43. WriteCouncilKick
44. WriteRoyalArmyKick
45. WriteChaosLegionKick
46. WriteResetFactions
47. WriteRemoveCharFromGuild
48. WriteShowName
49. WriteShowServerForm
50. WriteNight
51. WriteKickAllChars
52. WriteReloadServerIni
53. WriteReloadObjects
54. WriteReloadSpells
55. WriteRestart
56. WriteSaveMap
57. WriteCleanSOS
58. WriteShowDenouncesList
59. WriteSOSShowList
60. WriteSOSRemove
61. WriteEnableDenounces
62. WriteServerOpenToUsersToggle
63. WriteSetMOTD
64. WriteChangeMOTD
65. WriteSetTrigger
66. WriteAskTrigger
67. WriteTileBlockedToggle
68. WriteToggleCentinelActivated
69. WriteForceMIDIAll
70. WriteForceMIDIToMap
71. WriteForceWAVEAll
72. WriteForceWAVEToMap
73. WriteDestroyAllItemsInArea
74. WriteKillAllNearbyNPCs
75. WriteKillNPCNoRespawn
76. WriteResetNPCInventory
77. WriteRequestCharMail
78. WriteMakeDumb
79. WriteMakeDumbNoMore
80. WriteSilence
81. WriteWarnUser
82. WriteForumPost
83. WriteHome
84. WriteImitate
85. WriteSpawnListRequest
86. WriteSpawnCreature

## Notas
- Algunos comandos pueden estar duplicados con nombres ligeramente diferentes
- Algunos comandos GM pueden no ser necesarios en la versión inicial
- Priorizar según las necesidades del gameplay actual
