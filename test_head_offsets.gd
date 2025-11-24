extends Node

# Script para probar los offsets de cabeza en diferentes tipos de personajes
# Esto nos ayudará a verificar que enanos y gomos tengan las cabezas en la posición correcta

func _ready():
	print("=== Prueba de Offsets de Cabeza para Personajes ===")
	test_head_offsets()

func test_head_offsets():
	# Esperar a que GameAssets cargue los datos
	await get_tree().process_frame
	await get_tree().process_frame
	
	if not GameAssets.BodyAnimationList.size() > 0:
		print("❌ Error: No se cargaron los datos de cuerpos")
		return
	
	print("✅ Datos de cuerpos cargados: ", GameAssets.BodyAnimationList.size() - 1, " cuerpos")
	
	# Probar algunos cuerpos conocidos (valores aproximados según AO)
	var test_bodies = [1, 2, 3, 21, 22, 23, 34, 35, 36]  # Humanos, Elfos, Enanos, Gomos
	
	for body_id in test_bodies:
		if body_id < GameAssets.BodyAnimationList.size():
			var body_data = GameAssets.BodyAnimationList[body_id]
			print("Cuerpo %d: Offset(X=%d, Y=%d)" % [body_id, body_data.offsetX, body_data.offsetY])
			
			# Crear un personaje de prueba para visualizar
			create_test_character(body_id)

func create_test_character(body_id: int):
	var character_scene = preload("res://engine/character/character.tscn").instantiate()
	add_child(character_scene)
	
	# Posicionar en pantalla para fácil visualización
	var index = get_child_count() - 1
	character_scene.position = Vector2(100 + (index % 5) * 150, 100 + (index / 5) * 200)
	
	# Asignar cuerpo y cabeza de prueba
	character_scene.get_node("CharacterRenderer").body = body_id
	character_scene.get_node("CharacterRenderer").head = 1  # Cabeza humana estándar
	
	print("🎮 Personaje de prueba creado: Cuerpo %d en posición %s" % [body_id, character_scene.position])

func _input(event):
	if event.is_action_pressed("ui_accept"):
		print("\n=== Recargando prueba de offsets ===")
		# Limpiar personajes de prueba
		for child in get_children():
			if child is Node2D and child != self:
				child.queue_free()
		test_head_offsets()
