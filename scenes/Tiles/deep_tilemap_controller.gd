extends Node2D

@export var tilemap: TileMapLayer
@export var flip_duration := 0.6
@export var neutral_tile_atlas_coords: Vector2i = Vector2i(0, 0)
@export var player_tile_atlas_coords: Vector2i = Vector2i(1, 0)

var tile_set: TileSet
var flipping_tiles := {}  # Track currently flipping tiles

func _ready():
	if tilemap == null:
		tilemap = get_node("../HexTileMap")
	tile_set = tilemap.tile_set

func _input(event):
	if(Input.is_action_pressed("left_click")):
		var mouse_pos = get_global_mouse_position()
		print(mouse_pos)
		var cell_coords = tilemap.local_to_map(tilemap.to_local(mouse_pos))
		
		if is_valid_tile_to_capture(cell_coords):
			flip_tile(cell_coords)
		#place_tile(mouse_pos)
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			#var mouse_pos = get_global_mouse_position()
			#var cell_coords = tilemap.local_to_map(tilemap.to_local(mouse_pos))
			#
			#if is_valid_tile_to_capture(cell_coords):
				#flip_tile(cell_coords)

func is_valid_tile_to_capture(cell_coords: Vector2i) -> bool:
	# Check if tile exists and is neutral
	var source_id = tilemap.get_cell_source_id(cell_coords)
	if source_id == -1:  # No tile here
		return false
	
	# Check if tile is already owned by checking its atlas coords
	var atlas_coords = tilemap.get_cell_atlas_coords(cell_coords)
	if atlas_coords == player_tile_atlas_coords:
		return false
	
	# Check adjacency to player territory
	for neighbor in get_hex_neighbors(cell_coords):
		var neighbor_atlas = tilemap.get_cell_atlas_coords(neighbor)
		if neighbor_atlas == player_tile_atlas_coords:
			return true
	
	return false

func get_hex_neighbors(cell_coords: Vector2i) -> Array[Vector2i]:
	# Hex grid neighbors (assuming pointy-top hex layout)
	var neighbors: Array[Vector2i] = []
	var parity = cell_coords.y & 1  # Odd or even row
	
	# Define neighbor offsets based on row parity
	var offsets = [
		Vector2i(0, -1),    # North
		Vector2i(1, -1),    # Northeast (even), Southeast (odd)
		Vector2i(1, 0),     # East
		Vector2i(0, 1),     # South
		Vector2i(-1, 0),    # West
		Vector2i(-1, -1),   # Northwest (even), Southwest (odd)
	]
	
	if parity == 1:  # Odd row adjustment
		offsets[1] = Vector2i(1, -1)
		offsets[5] = Vector2i(0, -1)
	else:  # Even row adjustment
		offsets[1] = Vector2i(1, -1)
		offsets[5] = Vector2i(-1, -1)
	
	for offset in offsets:
		var neighbor = cell_coords + offset
		if tilemap.get_cell_source_id(neighbor) != -1:  # Check if tile exists
			neighbors.append(neighbor)
	
	return neighbors

func flip_tile(cell_coords: Vector2i):
	if flipping_tiles.has(cell_coords):
		return  # Already flipping
	
	flipping_tiles[cell_coords] = true
	
	# Get tile world position and size
	var cell_world_pos = tilemap.map_to_local(cell_coords)
	var cell_size = tilemap.cell_size
	
	# Create overlay sprite
	var overlay = Sprite2D.new()
	var source_id = tilemap.get_cell_source_id(cell_coords)
	var atlas_coords = tilemap.get_cell_atlas_coords(cell_coords)
	
	overlay.texture = tile_set.get_source(source_id).texture
	overlay.region_enabled = true
	overlay.region_rect = Rect2(
		atlas_coords * cell_size,
		cell_size
	)
	overlay.position = cell_world_pos + cell_size / 2
	overlay.z_index = 10  # Ensure it renders above the tilemap
	overlay.centered = true  # Ensure rotation happens around the center
	add_child(overlay)
	
	# Create tween for flip animation with rotation
	var tween = create_tween()
	tween.set_parallel(true)  # Allow multiple properties to animate at once
	
	# First half of flip: scale to 0 on X axis and rotate 90 degrees
	tween.tween_property(overlay, "scale", Vector2(0, 1), flip_duration / 2)
	tween.tween_property(overlay, "rotation_degrees", 90.0, flip_duration / 2)
	
	# Middle callback: change the actual tile and swap texture
	tween.tween_callback(_swap_tile_texture.bind(cell_coords, overlay))
	
	# Second half of flip: scale back to 1 on X axis and complete rotation
	tween.tween_property(overlay, "scale", Vector2(1, 1), flip_duration / 2)
	tween.tween_property(overlay, "rotation_degrees", 180.0, flip_duration / 2)
	
	# Cleanup
	tween.tween_callback(_remove_overlay.bind(overlay, cell_coords))

func _swap_tile_texture(cell_coords: Vector2i, overlay: Sprite2D):
	# Change the actual tile to player-owned version
	tilemap.set_cell(cell_coords, tilemap.get_cell_source_id(cell_coords), 
					player_tile_atlas_coords, 0)
	
	# Update overlay texture to show the new tile
	var source_id = tilemap.get_cell_source_id(cell_coords)
	overlay.texture = tile_set.get_source(source_id).texture
	overlay.region_rect = Rect2(
		player_tile_atlas_coords * tilemap.cell_size,
		tilemap.cell_size
	)

func _remove_overlay(overlay: Node, cell_coords: Vector2i):
	overlay.queue_free()
	flipping_tiles.erase(cell_coords)
