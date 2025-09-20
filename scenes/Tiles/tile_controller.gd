extends Node2D
class_name TileController

@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var highlight_tile_layer: HighlightTile = $TileMapLayer/HighlightTileLayer
@onready var interactable_layer: InteractableLayer = $Interactable

@onready var melt_logic: MeltLogic = $MeltLogic

@export var flip_duration := 0.5
@export var timeline: DialogicTimeline
@export var part: int

var interactive_tiles : Array[Vector2i]

var is_dragging := false
var processed_cells: Array[Vector2i] = []

func check_level_complete() -> bool:
	var used_cells: Array[Vector2i] = tile_map_layer.get_used_cells()

	for cell_coord in used_cells:
		var tile_data: TileData = tile_map_layer.get_cell_tile_data(cell_coord)

		if not tile_data:
			return false
		if tile_data.get_custom_data("can_change"):
			return false
	return true
	

func change_whole_board() -> void:
	for cell_coords in tile_map_layer.get_used_cells():
		
		pass


func _ready() -> void:

	melt_logic.tile_melted.connect(_on_tile_melted)
	melt_logic.snow_tile_added.connect(_on_snow_tile_added)
	if timeline !=null:
		Dialogic.start(timeline)

func _process(delta: float) -> void:
	if part != GameManager.current_part:
		set_process_input(false)
	
		
	var mouse_pos = get_global_mouse_position()
	var cell_coords = tile_map_layer.local_to_map(mouse_pos)
	var texture = get_cell_texture(cell_coords)
	if texture != null:
		Events.on_tile_hover.emit(texture)

func _on_tile_melted(cell_coords: Vector2i, previous_data: MeltLogic.SnowTileData) -> void:
	var global_pos = tile_map_layer.map_to_local(cell_coords)
	if GameManager.has_melted_tile == false:
		Events.on_tile_melted.emit()
		await get_tree().create_timer(5).timeout
		
	change_tile(cell_coords, global_pos, previous_data.previous_atlas_coords,0)
	print("Tile melted at ", cell_coords)

func _on_snow_tile_added(cell_coords: Vector2i) -> void:
	print("Snow tile added at ", cell_coords)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			processed_cells.clear()
			place_tile(get_global_mouse_position(), 1)
		else:
			is_dragging = false
			processed_cells.clear()
	elif event is InputEventMouseMotion and is_dragging:
		place_tile(get_global_mouse_position(), 1)

func change_tile(cell_coords: Vector2i, global_pos: Vector2, replacement_atlas_coords: Vector2i, source_id: int = 0) -> void:
	if processed_cells.has(cell_coords):
		return
	processed_cells.append(cell_coords)

	var old_texture = get_cell_texture(cell_coords)
	if old_texture:
		animate_placement(old_texture, global_pos)

	tile_map_layer.erase_cell(cell_coords)
	await get_tree().create_timer(flip_duration * 0.5).timeout
	tile_map_layer.set_cell(cell_coords, source_id, replacement_atlas_coords)

	processed_cells.erase(cell_coords)

# --- Placement with custom validation ---
func place_tile(mouse_pos: Vector2,source_id : int = 1) -> void:
	var cell_coords = tile_map_layer.local_to_map(mouse_pos)

#	Check if placement is an interactable
	if interactable_layer.tiles.has(cell_coords):
		Events.camera_movement_start.emit()
#		Camera zoom
		interactable_layer.tiles[cell_coords].interact()
		pass	
	
	if not can_tile_be_changed(cell_coords):
		return

	var global_pos = tile_map_layer.map_to_local(cell_coords)
	melt_logic.add_snow_tile(cell_coords)
	change_tile(cell_coords, global_pos, tile_map_layer.get_cell_atlas_coords(cell_coords),source_id)
	Events.on_tile_placement.emit()
	
	if check_level_complete():
		Events.exhausted_tiles.emit(part)
	
# --- Validation ---
func can_tile_be_changed(cell_coords: Vector2i) -> bool:
	var tile_data = tile_map_layer.get_cell_tile_data(cell_coords)
	if not tile_data:
		return false
	return tile_data.get_custom_data("can_change")

# --- Animation overlay ---
func animate_placement(from_texture: Texture2D, placement_location: Vector2) -> void:
	var overlay = Sprite2D.new()
	overlay.texture = from_texture
	overlay.position = placement_location
	overlay.centered = true
	add_child(overlay)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(overlay, "rotation", 2 * PI, flip_duration)
	tween.tween_property(overlay, "scale", Vector2.ZERO, flip_duration)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.finished.connect(_remove_overlay.bind(overlay))

func _remove_overlay(overlay: Sprite2D) -> void:
	if is_instance_valid(overlay):
		overlay.queue_free()

#region Helper functions
func get_cell_texture(coord: Vector2i) -> Texture2D:
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

func get_texture_from_atlas(atlas_coords: Vector2i) -> Texture2D:
	var source = tile_map_layer.tile_set.get_source(1)
	if not source or not source is TileSetAtlasSource:
		return null

	var atlas_source = source as TileSetAtlasSource
	if not atlas_source.has_tile(atlas_coords):
		return null

	var rect = atlas_source.get_tile_texture_region(atlas_coords)
	var image = atlas_source.texture.get_image()
	var tile_image = image.get_region(rect)
	return ImageTexture.create_from_image(tile_image)
#endregion
