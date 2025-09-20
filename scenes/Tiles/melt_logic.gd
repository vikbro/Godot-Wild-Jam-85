extends Node
class_name MeltLogic

# Signals to communicate with TileController
signal tile_melted(cell_coords: Vector2i, previous_data: SnowTileData)
signal snow_tile_added(cell_coords: Vector2i)
signal melting_rate_updated(cell_coords: Vector2i, melt_rate: float)

# Data structure to store information about snow tiles
class SnowTileData:
	var cell_coords: Vector2i
	var melt_timer: float
	var base_melt_time: float
	var melt_rate: float
	var previous_atlas_coords: Vector2i
	var is_melting: bool
	var neighbor_count: int
	
	func _init(coords: Vector2i, melt_time: float, prev_atlas: Vector2i):
		cell_coords = coords
		base_melt_time = melt_time
		melt_timer = melt_time
		melt_rate = 1.0
		previous_atlas_coords = prev_atlas
		is_melting = true
		neighbor_count = 0

@onready var tile_map_layer: TileMapLayer = $"../TileMapLayer"

var snow_tiles: Dictionary = {}  # Key: Vector2i cell coordinates, Value: SnowTileData
var melt_timer: Timer  # Store reference to the timer

@export var base_melt_time: float = 19
@export var neighbor_slow_factor: float = 0.7
@export var check_interval: float = 0.1

# Hexagonal neighbor directions
var hex_directions = [
	Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
	Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)
]

func _ready():
	Events.exhausted_tiles.connect(_onexhausted_tiles)
	start_melting()

func _onexhausted_tiles(part:int) -> void:
	var parent_part = $"..".part
	if part == parent_part:
		set_process(false)
		# Stop the melt timer instead of all children
		if melt_timer:
			melt_timer.stop()
		pass

func start_melting():
	melt_timer = Timer.new()  # Store the reference
	melt_timer.wait_time = check_interval
	melt_timer.timeout.connect(_process_melting)
	add_child(melt_timer)
	melt_timer.start()

func add_snow_tile(cell_coords: Vector2i):
	# Get the previous tile's atlas coordinates
	var prev_atlas_coords = tile_map_layer.get_cell_atlas_coords(cell_coords)
	
	# Create new snow tile data
	var snow_data = SnowTileData.new(cell_coords, base_melt_time, prev_atlas_coords)
	
	snow_tiles[cell_coords] = snow_data
	
	# Count initial neighbors and update rate
	snow_data.neighbor_count = count_snow_neighbors(cell_coords)
	update_melting_rate(cell_coords)
	
	update_neighbors_melting_rates(cell_coords)
	
	snow_tile_added.emit(cell_coords)

func _process_melting():
	# Process each snow tile
	for cell_coords in snow_tiles.keys():
		var snow_data = snow_tiles[cell_coords]
		
		if snow_data.is_melting:
			# Decrement the melt timer
			snow_data.melt_timer -= check_interval * snow_data.melt_rate
			#debug_tile_states()
			# Check if the tile should melt
			if snow_data.melt_timer <= 0:
				melt_tile(cell_coords)

func melt_tile(cell_coords: Vector2i):
	if not snow_tiles.has(cell_coords):
		return
	
	var snow_data = snow_tiles[cell_coords]
	tile_melted.emit(cell_coords, snow_data)
	
	snow_tiles.erase(cell_coords)
	
	# Update all neighbors of the melted tile
	update_neighbors_melting_rates(cell_coords)

func update_neighbors_melting_rates(melted_cell_coords: Vector2i):
	# Update melting rates for all neighbors of the melted tile
	for direction in hex_directions:
		var neighbor_coords = melted_cell_coords + direction
		if snow_tiles.has(neighbor_coords):
			update_melting_rate(neighbor_coords)
	
	# Also check if any tiles that were previously stopped should now start melting
	check_stopped_tiles_around(melted_cell_coords)

func check_stopped_tiles_around(center_coords: Vector2i):
	# Check a larger area (2 tiles radius) for tiles that might need updating
	var check_radius = 2
	for dx in range(-check_radius, check_radius + 1):
		for dy in range(-check_radius, check_radius + 1):
			var check_coords = center_coords + Vector2i(dx, dy)
			if snow_tiles.has(check_coords):
				var snow_data = snow_tiles[check_coords]
				if not snow_data.is_melting:
					# Re-evaluate if this stopped tile should start melting again
					update_melting_rate(check_coords)

func update_melting_rate(cell_coords: Vector2i):
	if not snow_tiles.has(cell_coords):
		return
	
	var snow_data = snow_tiles[cell_coords]
	var old_melting_state = snow_data.is_melting
	var old_melt_rate = snow_data.melt_rate
	
	# Count current neighbors
	snow_data.neighbor_count = count_snow_neighbors(cell_coords)
	
	# Determine melting behavior based on neighbor count
	if snow_data.neighbor_count >= 5:  # Well-insulated (5-6 neighbors)
		snow_data.is_melting = false
		snow_data.melt_rate = 0.0
	elif snow_data.neighbor_count > 0:  # Some insulation (1-4 neighbors)
		snow_data.is_melting = true
		# More gradual scaling - each neighbor provides some insulation
		var insulation_factor = snow_data.neighbor_count * neighbor_slow_factor / 6.0
		snow_data.melt_rate = 1.0 - insulation_factor
	else:  # No insulation (0 neighbors)
		snow_data.is_melting = true
		snow_data.melt_rate = 1.0
	
	# If state changed significantly, emit signal
	if old_melting_state != snow_data.is_melting or abs(old_melt_rate - snow_data.melt_rate) > 0.1:
		melting_rate_updated.emit(cell_coords, snow_data.melt_rate)

func count_snow_neighbors(cell_coords: Vector2i) -> int:
	var count = 0
	
	for direction in hex_directions:
		var neighbor_coords = cell_coords + direction
		if snow_tiles.has(neighbor_coords):
			count += 1
	
	return count

#DEBUG function
func force_update_all_melting_rates():
	for cell_coords in snow_tiles.keys():
		update_melting_rate(cell_coords)

func debug_tile_states():
	print("=== Tile States ===")
	for cell_coords in snow_tiles.keys():
		var data = snow_tiles[cell_coords]
		print("Tile %s: melting=%s, rate=%.2f, neighbors=%d, melt_timer=%.2f" % [
			cell_coords, data.is_melting, data.melt_rate, data.neighbor_count, data.melt_timer
		])
