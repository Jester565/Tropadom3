extends Node2D

class_name OverlaidNode2D

@export var debug_overlay_enabled_in_editor : bool = true
@export var debug_overlay_enabled_in_game : bool = true
@export var debug_overlay_color : Color = Color.GREEN
@export var debug_overlay_width : int = 2

var _debug_overlay_enabled : bool :
	get:
		return debug_overlay_enabled_in_editor if Engine.is_editor_hint() else debug_overlay_enabled_in_game

var _pixel_bounds: Rect2i

func _ready():
	if _debug_overlay_enabled:
		self.z_index = Globals.DEBUG_Z_INDEX

func _draw():
	if _debug_overlay_enabled:
		draw_rect(self._pixel_bounds, debug_overlay_color, false, debug_overlay_width)
