extends Node2D
class_name TileController

@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var highlight_layer: HighlightTile = $HighlightTile  # Assuming you have this
@export var flip_duration := 1.5  # Changed to more reasonable duration

var is_dragging := false
var processed_cells: Array[Vector2i] = []  # Track cells already processed during current drag



func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Start dragging
				is_dragging = true
				processed_cells.clear()
				var mouse_pos = get_global_mouse_position()
				place_tile(mouse_pos)
			else:
				# Stop dragging
				is_dragging = false
				processed_cells.clear()
	
	elif event is InputEventMouseMotion and is_dragging:
		var mouse_pos = get_global_mouse_position()
		place_tile(mouse_pos)

func place_tile(placement_position: Vector2) -> void:
	var cell_coords = tile_map_layer.local_to_map(placement_position)
	
	# Skip if we already processed this cell during current drag
	if processed_cells.has(cell_coords):
		return
	
	# Check if tile can be changed (custom data checks)
	if not can_tile_be_changed(cell_coords):
		return
	
	# Check if this cell already has the target tile
	var current_tile = tile_map_layer.get_cell_source_id(cell_coords)
	#if current_tile == 1:  # Assuming 1 is your target tile source_id
		#return
	
	# Mark this cell as processed
	processed_cells.append(cell_coords)
	
	Events.on_tile_placement.emit()
	
	# Get current tile data before erasing
	var atlas_coords = tile_map_layer.get_cell_atlas_coords(cell_coords)
	var global_pos = tile_map_layer.map_to_local(cell_coords)
	
	# Erase current tile
	tile_map_layer.erase_cell(cell_coords)
	
	# Animate the placement
	animate_placement(atlas_coords, global_pos)
	
	# Update tilemap with new tile after animation starts
	await get_tree().create_timer(flip_duration * 0.5).timeout  # Wait for animation to be halfway
	tile_map_layer.set_cell(cell_coords, 1, Vector2i(1, 3))

func can_tile_be_changed(cell_coords: Vector2i) -> bool:
	var tile_data = tile_map_layer.get_cell_tile_data(cell_coords)
	if not tile_data:
		return false
	
	# Check custom data layers
	var can_change = tile_data.get_custom_data("can_change")
	var is_winter = tile_data.get_custom_data("is_winter")
	
	return can_change

func animate_placement(tile_texture: Vector2i, tile_pos: Vector2) -> void:
	var overlay = Sprite2D.new()
	var texture = get_cell_texture(tile_texture)
	#overlay.z_index = -1
	if texture:
		overlay.texture = texture
	
	# Adjust position properly
	var tile_data = tile_map_layer.get_cell_tile_data(tile_texture)
	if tile_data == null || tile_data.texture_origin == null: 
		return
	overlay.position = tile_pos - Vector2(tile_data.texture_origin)
	overlay.centered = true
	add_child(overlay)

	# Create tween for spin and scale animation
	var tween = create_tween()
	tween.set_parallel(true)

	# Spin animation: rotate 360 degrees
	tween.tween_property(overlay, "rotation", 2 * PI, flip_duration)

	# Scale down animation: shrink to 0
	tween.tween_property(overlay, "scale", Vector2.ZERO, flip_duration)

	# Set easing for smooth animation
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)

	# Cleanup after animation completes
	tween.finished.connect(_remove_overlay.bind(overlay))

func _remove_overlay(overlay: Sprite2D) -> void:
	if is_instance_valid(overlay):
		overlay.queue_free()

#TODO FIX this function
func get_cell_texture(coord: Vector2i) -> Texture:
	var source_id = tile_map_layer.get_cell_source_id(coord)
	if source_id == -1:
		return null
	
	var source = tile_map_layer.tile_set.get_source(source_id)
	if not source or not source is TileSetAtlasSource:
		return null
	
	var atlas_source = source as TileSetAtlasSource
	var atlas_coords = tile_map_layer.get_cell_atlas_coords(coord)
	
	if not atlas_source.has_tile(atlas_coords):
		return null
	
	var rect = atlas_source.get_tile_texture_region(atlas_coords)
	var image = atlas_source.texture.get_image()
	var tile_image = image.get_region(rect)
	return ImageTexture.create_from_image(tile_image)
