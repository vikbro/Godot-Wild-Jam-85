extends TileMapLayer
class_name InteractableLayer
#@onready var tile_map_layer: TileMapLayer = $"../TileMapLayer"

var tiles : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_child_entered_tree(node: Node) -> void:
	if node is PlaceholderInteractable:
		node.tile_coords = local_to_map(node.position)
		tiles[local_to_map(node.position)] = node
		
	pass # Replace with function body.
