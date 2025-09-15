extends Node2D
class_name TileController

@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var highlight_layer: HighlightTile = $HighlightTile  # Assuming you have this
@export var flip_duration := 5  # Changed to more reasonable duration
@onready var melt_logic: MeltLogic = $MeltLogic


var is_dragging := false
var processed_cells: Array[Vector2i] = []  # Track cells already processed during current drag

func _process(delta: float) -> void:
#	This is for debug purpose
	#var mouse_pos = get_global_mouse_position()
	#var cell_cords = tile_map_layer.local_to_map(mouse_pos)
	#Events.on_tile_hover.emit(get_cell_texture(cell_cords))
	pass

func _ready() -> void:
	Events.exhausted_tiles.connect(_on_tiles_exhausted)
	melt_logic.tile_melted.connect(_on_tile_melted)
	melt_logic.snow_tile_added.connect(_on_snow_tile_added)

func _on_tile_melted(cell_coords: Vector2i, previous_data: MeltLogic.SnowTileData) -> void:
	place_tile(cell_coords,previous_data.previous_atlas_coords)
	print("Tile melted at ", cell_coords)

func _on_snow_tile_added(cell_coords: Vector2i) -> void:
	print("Snow tile added at ", cell_coords)

func _on_tiles_exhausted():
	set_process_input(false)
	print("Input processing disabled due to exhausted tiles")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Start dragging
				is_dragging = true
				processed_cells.clear()
				var mouse_pos = get_global_mouse_position()
				if can_tile_be_changed(tile_map_layer.local_to_map(mouse_pos)):
					place_tile(mouse_pos)
					return
			else:
				# Stop dragging
				is_dragging = false
				processed_cells.clear()
				
	
	elif event is InputEventMouseMotion and is_dragging:
		var mouse_pos = get_global_mouse_position()
		if can_tile_be_changed(tile_map_layer.local_to_map(mouse_pos)):
			place_tile(mouse_pos)

func place_tile(placement_position: Vector2,replacement_tile_texture : Vector2i = Vector2i(1,3)) -> void:
	var cell_coords = tile_map_layer.local_to_map(placement_position)
	
	# Skip if we already processed this cell during current drag
	if processed_cells.has(cell_coords):
		return
	
	# Check if tile can be changed (custom data checks)
	#TODO validation should not be in placement SOLID
	#if not can_tile_be_changed(cell_coords):
		#return
	
	# Check if this cell already has the target tile
	var current_tile = tile_map_layer.get_cell_source_id(cell_coords)
	#if current_tile == 1:  # Assuming 1 is your target tile source_id
		#return
	
	# Mark this cell as processed
	processed_cells.append(cell_coords)
	
	
	# Get current tile data before erasing
	var atlas_coords = tile_map_layer.get_cell_atlas_coords(cell_coords)
	var global_pos = tile_map_layer.map_to_local(cell_coords)
	
	Events.on_tile_placement.emit()
	# Erase current tile
	tile_map_layer.erase_cell(cell_coords)
	
	# Animate the placement FROM image, TO image
	animate_placement(cell_coords,replacement_tile_texture, global_pos)
	
	# Update tilemap with new tile after animation starts
	await get_tree().create_timer(flip_duration * 0.5).timeout  # Wait for animation to be halfway
	tile_map_layer.set_cell(cell_coords, 1, replacement_tile_texture)
	melt_logic.add_snow_tile(cell_coords)

func can_tile_be_changed(cell_coords: Vector2i) -> bool:
	var tile_data = tile_map_layer.get_cell_tile_data(cell_coords)
	if not tile_data:
		return false
	
	# Check custom data layers
	var can_change = tile_data.get_custom_data("can_change")
	var is_winter = tile_data.get_custom_data("is_winter")
	
	return can_change

# (Change from , Change to)
func animate_placement(from_tile_cords: Vector2i , to_tile_atlas_cords: Vector2i,placement_location: Vector2) -> void:
#	The overlay is the previous tile (NOT SNOW)
	var overlay = Sprite2D.new()
	var texture = get_cell_texture(from_tile_cords)
	Events.on_tile_hover.emit(texture)
	#overlay.z_index = -1
	if texture:
		overlay.texture = texture
	
	# Adjust position properly
	var tile_data = tile_map_layer.get_cell_tile_data(from_tile_cords)
	if tile_data == null || tile_data.texture_origin == null: 
		return
	overlay.position = placement_location - Vector2(tile_data.texture_origin)
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

#Takes the coords in the TileMapLayer. Not in the atlas!
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
