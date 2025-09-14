extends Node2D
class_name TileController

signal highlight_cell(cell_coords: Vector2i)


@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@export var flip_duration := 5
@onready var highlight_tile_layer: TileMapLayer = $HighlightTileLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass

func _input(event: InputEvent) -> void:
	if(Input.is_action_pressed("left_click")):
		var mouse_pos = get_global_mouse_position()
		print(mouse_pos)
		place_tile(mouse_pos)


func place_tile(placement_position) -> void:
	var cell_coords = tile_map_layer.local_to_map(placement_position)
	tile_map_layer.erase_cell(cell_coords)

#Wait for the animation
	animate_placement(tile_map_layer.get_cell_atlas_coords(cell_coords), self.to_global(
		tile_map_layer.map_to_local(cell_coords)))

#	Update tilemap
	tile_map_layer.set_cell(tile_map_layer.local_to_map(get_global_mouse_position()),1,Vector2i(1,3))
	

func animate_placement(tile_texture: Vector2i, tile_pos: Vector2) -> void:
	var overlay = Sprite2D.new()
	overlay.texture = get_cell_texture(tile_texture)
	#tile_map_layer.get_cell_tile_data(tile_pos).texture_origin
	overlay.position = tile_pos - Vector2(tile_map_layer.get_cell_tile_data(tile_texture).texture_origin)
	overlay.centered = true  # Ensure sprite is centered on position
	add_child(overlay)

	# Create tween for spin and scale animation
	var tween = create_tween()
	tween.set_parallel(true)  # Run both animations simultaneously

	# Spin animation: rotate 360 degrees (2 * PI radians)
	tween.tween_property(overlay, "rotation", 2 * PI, flip_duration)

	# Scale down animation: shrink to 0
	tween.tween_property(overlay, "scale", Vector2.ZERO, flip_duration)

	# Set easing for smooth animation
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)

	# Cleanup after animation completes
	tween.finished.connect(_remove_overlay.bind(overlay))

# Cleanup function
func _remove_overlay(overlay: Sprite2D) -> void:
	if is_instance_valid(overlay):
		overlay.queue_free()
		

func get_cell_texture(coord:Vector2i) -> Texture:
	var source_id := tile_map_layer.get_cell_source_id(coord)
	var source:TileSetAtlasSource = tile_map_layer.tile_set.get_source(source_id) as TileSetAtlasSource
	var altas_coord := tile_map_layer.get_cell_atlas_coords(coord)
	var rect := source.get_tile_texture_region(altas_coord)
	var image:Image = source.texture.get_image()
	var tile_image := image.get_region(rect)
	return ImageTexture.create_from_image(tile_image)
