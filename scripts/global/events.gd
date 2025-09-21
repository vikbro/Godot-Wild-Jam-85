extends Node

#Tiles
signal on_tile_placement
signal on_tile_melted
signal on_tile_removal
signal on_tile_hover

#Interactable Tile
signal birds_fly(flying: bool)

#Tiles logic
signal is_valid_placement(cell_coords : Vector2i)
signal exhausted_tiles(part: int)
signal unavaliable_tile_placement
signal stop_placement
signal start_placement

#Camera
signal camera_movement_start(pos: Vector2)
signal camera_movement_stop
signal camera_after_anim
signal camera_after_anim_finish

#UI
signal higlight_tile_ui

#Dice
signal roll_dice
signal roll_finished(number:int)

#Dialogic
signal timeline_started
signal timeline_ended
