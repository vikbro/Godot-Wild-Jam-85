extends Node

#Tiles
signal on_tile_placement
signal on_tile_melted
signal on_tile_removal
signal on_tile_hover

#Tiles logic
signal is_valid_placement(cell_coords : Vector2i)
signal exhausted_tiles
signal unavaliable_tile_placement

#Camera
signal camera_movement_start
signal camera_movement_stop

#UI
signal higlight_tile_ui

#Dice
signal roll_dice

#Dialogic
signal timeline_started
signal timeline_ended
