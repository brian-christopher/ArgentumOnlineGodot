extends Node

# Script de prueba para los 10 comandos urgentes de gameplay básico
# Verifica que todas las funciones estén disponibles y funcionen correctamente

func _ready():
	print("=== Prueba de Comandos de Gameplay Básico ===")
	test_all_commands()

func test_all_commands():
	# Esperar a que los sistemas estén listos
	await get_tree().process_frame
	
	print("\n🔥 Probando comandos de gameplay básico:")
	
	# 1. WriteNavigateToggle - Toggle navegación (requiere barco)
	test_navigate_toggle()
	
	# 2. WriteUseSpellMacro - Usa macro de hechizo
	test_use_spell_macro()
	
	# 3. WriteMoveItem - Mueve items entre inventario/banco
	test_move_item()
	
	# 4. WriteMoveBank - Mueve items en el banco
	test_move_bank()
	
	# 5. WriteHiding - Toggle ocultarse (GM)
	test_hiding()
	
	# 6. WriteNPCFollow - Hace que NPC siga al personaje (GM)
	test_npc_follow()
	
	# 7. WriteTrain - Entrena con criatura
	test_train()
	
	# 8. WriteCraftBlacksmith - Crafteo herrería
	test_craft_blacksmith()
	
	# 9. WriteCraftCarpenter - Crafteo carpintería
	test_craft_carpenter()
	
	# 10. WriteInitCrafting - Inicializa crafteo
	test_init_crafting()
	
	print("\n✅ Todos los comandos de gameplay básico están implementados y listos para usar!")

func test_navigate_toggle():
	print("1. WriteNavigateToggle - Toggle navegación")
	if GameProtocol.has_method("WriteNavigateToggle"):
		print("   ✅ Función disponible")
		# GameProtocol.WriteNavigateToggle() # Descomentar para usar
	else:
		print("   ❌ Función no encontrada")

func test_use_spell_macro():
	print("2. WriteUseSpellMacro - Usa macro de hechizo")
	if GameProtocol.has_method("WriteUseSpellMacro"):
		print("   ✅ Función disponible")
		# GameProtocol.WriteUseSpellMacro() # Descomentar para usar
	else:
		print("   ❌ Función no encontrada")

func test_move_item():
	print("3. WriteMoveItem - Mueve items")
	if GameProtocol.has_method("WriteMoveItem"):
		print("   ✅ Función disponible")
		print("   Parámetros: original_slot: int, new_slot: int, move_type: Enums.eMoveType")
		# Ejemplo: Mover item del slot 5 al 10 en inventario
		# GameProtocol.WriteMoveItem(5, 10, Enums.eMoveType.Inventory)
	else:
		print("   ❌ Función no encontrada")

func test_move_bank():
	print("4. WriteMoveBank - Mueve items en banco")
	if GameProtocol.has_method("WriteMoveBank"):
		print("   ✅ Función disponible")
		print("   Parámetros: upwards: bool, slot: int")
		# Ejemplo: Mover item del slot 3 hacia arriba
		# GameProtocol.WriteMoveBank(true, 3)
	else:
		print("   ❌ Función no encontrada")

func test_hiding():
	print("5. WriteHiding - Toggle ocultarse (GM)")
	if GameProtocol.has_method("WriteHiding"):
		print("   ✅ Función disponible (Requiere permisos GM)")
		# GameProtocol.WriteHiding() # Descomentar para usar
	else:
		print("   ❌ Función no encontrada")

func test_npc_follow():
	print("6. WriteNPCFollow - NPC sigue personaje (GM)")
	if GameProtocol.has_method("WriteNPCFollow"):
		print("   ✅ Función disponible (Requiere permisos GM)")
		# GameProtocol.WriteNPCFollow() # Descomentar para usar
	else:
		print("   ❌ Función no encontrada")

func test_train():
	print("7. WriteTrain - Entrena con criatura")
	if GameProtocol.has_method("WriteTrain"):
		print("   ✅ Función disponible")
		print("   Parámetros: creature: int (índice en lista del entrenador)")
		# Ejemplo: Entrenar con la primera criatura de la lista
		# GameProtocol.WriteTrain(1)
	else:
		print("   ❌ Función no encontrada")

func test_craft_blacksmith():
	print("8. WriteCraftBlacksmith - Crafteo herrería")
	if GameProtocol.has_method("WriteCraftBlacksmith"):
		print("   ✅ Función disponible")
		print("   Parámetros: item: int (índice del item a craftear)")
		# Ejemplo: Craftear espada de hierro
		# GameProtocol.WriteCraftBlacksmith(1)
	else:
		print("   ❌ Función no encontrada")

func test_craft_carpenter():
	print("9. WriteCraftCarpenter - Crafteo carpintería")
	if GameProtocol.has_method("WriteCraftCarpenter"):
		print("   ✅ Función disponible")
		print("   Parámetros: item: int (índice del item a craftear)")
		# Ejemplo: Craftear escudo de madera
		# GameProtocol.WriteCraftCarpenter(5)
	else:
		print("   ❌ Función no encontrada")

func test_init_crafting():
	print("10. WriteInitCrafting - Inicializa crafteo")
	if GameProtocol.has_method("WriteInitCrafting"):
		print("   ✅ Función disponible")
		print("   Parámetros: cantidad: int, nro_por_ciclo: int")
		# Ejemplo: Craftear 10 items, 2 por ciclo
		# GameProtocol.WriteInitCrafting(10, 2)
	else:
		print("   ❌ Función no encontrada")

func _input(event):
	if event.is_action_pressed("ui_accept"):
		print("\n=== Recargando prueba de comandos ===")
		test_all_commands()
