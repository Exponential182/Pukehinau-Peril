extends Node

## Credits Crawl — Star Wars style
## Renders scrolling text into a SubViewport, displays it on a tilted 3D plane.
## Perspective naturally makes text shrink toward the horizon.
##
## USAGE (pure code, no .tscn needed):
##   var credits = preload("res://credits_crawl.gd").new()
##   add_child(credits)
##   credits.credits_finished.connect(my_callback)

# ── Configuration ─────────────────────────────────────────────────────────────

## Pixels per second the text scrolls upward inside the viewport texture.
@export var scroll_speed: float = 80.0

## X rotation of the plane in degrees. Negative tilts top away from camera.
@export var plane_tilt_degrees: float = -55.0

## How far in front of the camera the plane sits (metres).
@export var plane_distance: float = 1.8

## Size of the 3D plane (metres).
@export var plane_width: float = 4.0
@export var plane_height: float = 3.0

## Texture resolution of the SubViewport.
@export var viewport_size: Vector2i = Vector2i(1024, 1536)

## Camera vertical FOV.
@export var camera_fov: float = 60.0

## Height of fade gradient at top/bottom of viewport (px).
@export var fade_px: float = 180.0

## Free self and emit signal when scrolling ends.
@export var auto_free: bool = true

# ── Credits data ──────────────────────────────────────────────────────────────
## { "header": "Text" }              → big yellow centred title
## { "role": "...", "names": [...] } → role label + name list
## Names accept "Name // Sub-label" syntax.

var credits_data: Array = [
	{"header": "A Game by\nExample Studio"},

	{"role": "Direction", "names": [
		"Jane Doe",
	]},

	{"role": "Programming", "names": [
		"Jane Doe",
		"John Smith // Engine & Tools",
		"Alex Rivera // UI Systems",
	]},

	{"role": "Art Direction", "names": [
		"Sam Lee",
	]},

	{"role": "Environment Art", "names": [
		"Sam Lee",
		"Morgan Chen",
		"Taylor Brooks",
	]},

	{"role": "Character Art", "names": [
		"Morgan Chen",
	]},

	{"role": "Animation", "names": [
		"Jordan Park",
		"Casey Kim // Cinematics",
	]},

	{"role": "Music & Sound Design", "names": [
		"Riley Torres",
	]},

	{"role": "Narrative Design", "names": [
		"Avery Johnson",
		"Quinn Patel",
	]},

	{"role": "QA Lead", "names": [
		"Blake Martinez",
	]},

	{"role": "QA Testers", "names": [
		"Drew Wilson",
		"Sage Thompson",
		"Cam Harris",
	]},

	{"header": "Special Thanks"},

	{"role": "Beta Testers", "names": [
		"Everyone who played the demo",
		"The Godot community",
	]},

	{"role": "Made With", "names": [
		"Godot Engine 4",
		"Blender",
		"Krita",
	]},

	{"header": "Thank you\nfor playing."},
]

# ── Signals ───────────────────────────────────────────────────────────────────

signal credits_finished

# ── Private ───────────────────────────────────────────────────────────────────

var _subviewport: SubViewport
var _vbox: VBoxContainer
var _world: Node3D
var _camera: Camera3D
var _mesh_instance: MeshInstance3D
var _bg_layer: CanvasLayer
var _ui_layer: CanvasLayer
var _scrolling: bool = false
var _scroll_offset: float = 0.0
var _content_height: float = 0.0

# ── Lifecycle ─────────────────────────────────────────────────────────────────

func _ready() -> void:
	_build()
	# Wait two frames so the VBoxContainer has laid out and measured its children
	await get_tree().process_frame
	await get_tree().process_frame
	_content_height = _vbox.size.y
	_vbox.position.y = float(viewport_size.y)   # start below the visible texture
	_scroll_offset = 0.0
	_scrolling = true


func _process(delta: float) -> void:
	if not _scrolling:
		return
	_scroll_offset += scroll_speed * delta
	_vbox.position.y = float(viewport_size.y) - _scroll_offset
	if _vbox.position.y + _content_height < 0.0:
		_scrolling = false
		credits_finished.emit()
		if auto_free:
			queue_free()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		skip_credits()

# ── Public ────────────────────────────────────────────────────────────────────

func pause_credits() -> void:
	_scrolling = false

func resume_credits() -> void:
	_scrolling = true

func skip_credits() -> void:
	_scrolling = false
	credits_finished.emit()
	if auto_free:
		queue_free()

# ── Construction ──────────────────────────────────────────────────────────────

func _build() -> void:
	# ── Black background (behind the 3D scene) ──────────────────────────────
	_bg_layer = CanvasLayer.new()
	_bg_layer.layer = -10
	add_child(_bg_layer)
	var bg := ColorRect.new()
	bg.color = Color.BLACK
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_bg_layer.add_child(bg)

	# ── 3D world ────────────────────────────────────────────────────────────
	_world = Node3D.new()
	add_child(_world)

	_camera = Camera3D.new()
	_camera.fov = camera_fov
	_camera.position = Vector3(0.0, 0.6, 2.2)
	_camera.rotation_degrees.x = -8.0
	_world.add_child(_camera)

	# ── SubViewport ─────────────────────────────────────────────────────────
	_subviewport = SubViewport.new()
	_subviewport.size = viewport_size
	_subviewport.transparent_bg = false
	_subviewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_subviewport)   # must be in the tree to render

	var vp_bg := ColorRect.new()
	vp_bg.color = Color.BLACK
	vp_bg.size = Vector2(viewport_size)
	_subviewport.add_child(vp_bg)

	_vbox = VBoxContainer.new()
	_vbox.custom_minimum_size.x = float(viewport_size.x)
	_vbox.add_theme_constant_override("separation", 0)
	_subviewport.add_child(_vbox)
	_populate_vbox()

	# Fade overlays baked into the texture
	_subviewport.add_child(_make_fade(
		Vector2(0, 0),
		Vector2(float(viewport_size.x), fade_px),
		Color.BLACK, Color(0, 0, 0, 0)
	))
	_subviewport.add_child(_make_fade(
		Vector2(0, float(viewport_size.y) - fade_px),
		Vector2(float(viewport_size.x), fade_px),
		Color(0, 0, 0, 0), Color.BLACK
	))

	# ── Tilted plane ─────────────────────────────────────────────────────────
	_mesh_instance = MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(plane_width, plane_height)
	_mesh_instance.mesh = plane
	_mesh_instance.rotation_degrees.x = plane_tilt_degrees
	_mesh_instance.position = Vector3(0.0, -0.4, -plane_distance)

	var mat := StandardMaterial3D.new()
	mat.albedo_texture = _subviewport.get_texture()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	_mesh_instance.set_surface_override_material(0, mat)
	_world.add_child(_mesh_instance)

	# ── Skip hint ────────────────────────────────────────────────────────────
	_ui_layer = CanvasLayer.new()
	_ui_layer.layer = 10
	add_child(_ui_layer)
	var skip_lbl := Label.new()
	skip_lbl.text = "ESC  to skip"
	skip_lbl.add_theme_font_size_override("font_size", 14)
	skip_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.3))
	skip_lbl.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	skip_lbl.offset_left = -160
	skip_lbl.offset_top = -36
	_ui_layer.add_child(skip_lbl)


func _populate_vbox() -> void:
	_add_spacer(120)
	for entry in credits_data:
		if entry.has("header"):
			_add_header(entry["header"])
		else:
			_add_section(entry.get("role", ""), entry.get("names", []))
		_add_spacer(72)
	# Trailing space so last line scrolls fully off screen
	_add_spacer(float(viewport_size.y))


func _add_header(text: String) -> void:
	_add_spacer(40)
	var lbl := Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.custom_minimum_size.x = float(viewport_size.x)
	lbl.add_theme_font_size_override("font_size", 52)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.1, 1.0))
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	_vbox.add_child(lbl)
	_add_spacer(20)


func _add_section(role: String, names: Array) -> void:
	if role != "":
		var rl := Label.new()
		rl.text = role.to_upper()
		rl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rl.custom_minimum_size.x = float(viewport_size.x)
		rl.add_theme_font_size_override("font_size", 24)
		rl.add_theme_color_override("font_color", Color(0.55, 0.55, 0.55, 1.0))
		_vbox.add_child(rl)
		_add_spacer(10)

	for raw: String in names:
		var parts := raw.split("//")
		var display: String = parts[0].strip_edges()
		var sub: String = parts[1].strip_edges() if parts.size() > 1 else ""

		var nl := Label.new()
		nl.text = display
		nl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		nl.custom_minimum_size.x = float(viewport_size.x)
		nl.add_theme_font_size_override("font_size", 34)
		nl.add_theme_color_override("font_color", Color.WHITE)
		_vbox.add_child(nl)

		if sub != "":
			var sl := Label.new()
			sl.text = sub
			sl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			sl.custom_minimum_size.x = float(viewport_size.x)
			sl.add_theme_font_size_override("font_size", 22)
			sl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1.0))
			_vbox.add_child(sl)

		_add_spacer(8)


func _add_spacer(height: float) -> void:
	var s := Control.new()
	s.custom_minimum_size.y = height
	_vbox.add_child(s)


func _make_fade(pos: Vector2, sz: Vector2, top_col: Color, bot_col: Color) -> TextureRect:
	var grad := Gradient.new()
	grad.colors = PackedColorArray([top_col, bot_col])
	grad.offsets = PackedFloat32Array([0.0, 1.0])

	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.fill_from = Vector2(0.5, 0.0)
	tex.fill_to   = Vector2(0.5, 1.0)

	var tr := TextureRect.new()
	tr.position = pos
	tr.size = sz
	tr.z_index = 10
	tr.texture = tex
	tr.stretch_mode = TextureRect.STRETCH_SCALE
	return tr
