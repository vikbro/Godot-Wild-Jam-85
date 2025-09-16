extends Node
class_name MeltLogic

# Signals
signal tile_melted(cell_coords, previous_tile_data)
signal snow_tile_added(cell_coords)

# Configuration
@export var base_melt_time: float = 10       # Base time to melt (seconds)
@export var neighbor_melt_penalty: float = 2.0 # Extra time per snow neighbor
@export var check_interval: float = 0.5       # How often to check melting (seconds)

# Data storage
var snow_tiles: Dictionary = {}  # cell_coords -> SnowTileData
var melt_timers: Dictionary = {} # cell_coords -> SceneTreeTimer

# Tile data structure
class SnowTileData:
	var cell_coords: Vector2i
	var previous_source_id: int
	var previous_atlas_coords: Vector2i
	var previous_alternative_id: int
	var creation_time: float
	var neighbors: Array[Vector2i] = []
	
	func _init(coords: Vector2i, source_id: int, atlas_coords: Vector2i, alt_id: int):
		cell_coords = coords
		previous_source_id = source_id
		previous_atlas_coords = atlas_coords
		previous_alternative_id = alt_id
		creation_time = Time.get_unix_time_from_system()

# Reference to TileMapLayer
@onready var tile_map_layer: TileMapLayer = $"../TileMapLayer"

# Persistent timer for periodic checking
var check_timer: Timer

func _ready() -> void:
	check_timer = Timer.new()
	check_timer.wait_time = check_interval
	check_timer.one_shot = false
	check_timer.autostart = true
	add_child(check_timer)
	check_timer.timeout.connect(_check_melting)

func _check_melting() -> void:
	var current_time = Time.get_unix_time_from_system()
	
	for cell_coords in snow_tiles.keys():

		var snow_data: SnowTileData = snow_tiles[cell_coords]

		# Surrounded by snow → can't melt
		if _is_surrounded_by_snow(cell_coords):
			melt_timers.erase(cell_coords) # let any old timer expire naturally
			continue
		
		# Calculate melt time
		var melt_time = base_melt_time + (_count_snow_neighbors(cell_coords) * neighbor_melt_penalty)
		var elapsed_time = current_time - snow_data.creation_time
		var remaining_time = max(0.1, melt_time - elapsed_time)
		print(cell_coords, remaining_time)
		# Schedule melt if not already scheduled
		if not melt_timers.has(cell_coords):
			var melt_timer: SceneTreeTimer = get_tree().create_timer(remaining_time)
			melt_timer.timeout.connect(_melt_tile.bind(cell_coords))
			melt_timers[cell_coords] = melt_timer

func _melt_tile(cell_coords: Vector2i) -> void:
	if not snow_tiles.has(cell_coords):
		return
	
	var snow_data: SnowTileData = snow_tiles[cell_coords]
	
	# Restore previous tile
	tile_map_layer.set_cell(
		cell_coords,
		snow_data.previous_source_id,
		snow_data.previous_atlas_coords,
		snow_data.previous_alternative_id
	)
	
	# Clean up
	snow_tiles.erase(cell_coords)
	melt_timers.erase(cell_coords) # SceneTreeTimer auto-frees
	
	# Emit signal
	tile_melted.emit(cell_coords, snow_data)
	
	# Update neighbors
	_update_neighbor_tiles(cell_coords)

func add_snow_tile(cell_coords: Vector2i) -> void:
	# Save previous tile
	var source_id = tile_map_layer.get_cell_source_id(cell_coords)
	var atlas_coords = tile_map_layer.get_cell_atlas_coords(cell_coords)
	var alternative_id = tile_map_layer.get_cell_alternative_tile(cell_coords)
	
	var snow_data = SnowTileData.new(cell_coords, source_id, atlas_coords, alternative_id)
	snow_tiles[cell_coords] = snow_data
	
	# Place snow (example: source_id 1, atlas_coords (1,3))
	tile_map_layer.set_cell(cell_coords, 1, Vector2i(1, 3), 0)
	
	# Emit signal
	snow_tile_added.emit(cell_coords)
	
	# Update neighbors
	_update_neighbor_tiles(cell_coords)

func _update_neighbor_tiles(center_coords: Vector2i) -> void:
	if snow_tiles.has(center_coords):
		var snow_data: SnowTileData = snow_tiles[center_coords]
		snow_data.neighbors = tile_map_layer.get_surrounding_cells(center_coords)
	
	for neighbor_coords in tile_map_layer.get_surrounding_cells(center_coords):
		if snow_tiles.has(neighbor_coords):
			var neighbor_data: SnowTileData = snow_tiles[neighbor_coords]
			neighbor_data.neighbors = tile_map_layer.get_surrounding_cells(neighbor_coords)
			
			# Remove old melt timer → will be rescheduled on next _check_melting
			melt_timers.erase(neighbor_coords)

func _count_snow_neighbors(cell_coords: Vector2i) -> int:
	var count := 0
	var tile_data = tile_map_layer.get_cell_tile_data(cell_coords)
	if not tile_data:
		return false
	
	# Check custom data layers
	var can_change = tile_data.get_custom_data("can_change")
	var is_winter = tile_data.get_custom_data("is_winter")
	
	for neighbor_coords: Vector2i in tile_map_layer.get_surrounding_cells(cell_coords):
		if snow_tiles.has(neighbor_coords) or tile_map_layer.get_cell_source_id(neighbor_coords) == 1:
			count += 1
	return count

func _is_surrounded_by_snow(cell_coords: Vector2i) -> bool:
	for neighbor_coords in tile_map_layer.get_surrounding_cells(cell_coords):
		#if not snow_tiles.has(neighbor_coords) and tile_map_layer.get_cell_source_id(neighbor_coords) != 1:
		if not snow_tiles.has(neighbor_coords):
			return false
	return true

# Debug / utility
func force_melt_tile(cell_coords: Vector2i) -> void:
	if snow_tiles.has(cell_coords):
		_melt_tile(cell_coords)

func _exit_tree() -> void:
	melt_timers.clear() # SceneTreeTimers auto-clean

func get_snow_tiles() -> Array[Vector2i]:
	return snow_tiles.keys()

func is_snow_tile(cell_coords: Vector2i) -> bool:
	return snow_tiles.has(cell_coords)
